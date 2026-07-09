/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.upec.controller;

import com.upec.controller.exceptions.IllegalOrphanException;
import com.upec.controller.exceptions.NonexistentEntityException;
import com.upec.controller.exceptions.RollbackFailureException;
import java.io.Serializable;
import jakarta.persistence.Query;
import jakarta.persistence.EntityNotFoundException;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Root;
import com.upec.model.Marca;
import com.upec.model.Modelo;
import com.upec.model.Vehiculo;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.transaction.UserTransaction;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author ACER NITRO V15
 */
public class ModeloJpaController implements Serializable {

    public ModeloJpaController(UserTransaction utx, EntityManagerFactory emf) {
        this.utx = utx;
        this.emf = emf;
    }
    private UserTransaction utx = null;
    private EntityManagerFactory emf = null;

    public EntityManager getEntityManager() {
        return emf.createEntityManager();
    }

    public void create(Modelo modelo) throws RollbackFailureException, Exception {
        if (modelo.getVehiculoList() == null) {
            modelo.setVehiculoList(new ArrayList<Vehiculo>());
        }
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            Marca IDMarca = modelo.getIDMarca();
            if (IDMarca != null) {
                IDMarca = em.getReference(IDMarca.getClass(), IDMarca.getIDMarca());
                modelo.setIDMarca(IDMarca);
            }
            List<Vehiculo> attachedVehiculoList = new ArrayList<Vehiculo>();
            for (Vehiculo vehiculoListVehiculoToAttach : modelo.getVehiculoList()) {
                vehiculoListVehiculoToAttach = em.getReference(vehiculoListVehiculoToAttach.getClass(), vehiculoListVehiculoToAttach.getIDVehiculo());
                attachedVehiculoList.add(vehiculoListVehiculoToAttach);
            }
            modelo.setVehiculoList(attachedVehiculoList);
            em.persist(modelo);
            if (IDMarca != null) {
                IDMarca.getModeloList().add(modelo);
                IDMarca = em.merge(IDMarca);
            }
            for (Vehiculo vehiculoListVehiculo : modelo.getVehiculoList()) {
                Modelo oldIDModeloOfVehiculoListVehiculo = vehiculoListVehiculo.getIDModelo();
                vehiculoListVehiculo.setIDModelo(modelo);
                vehiculoListVehiculo = em.merge(vehiculoListVehiculo);
                if (oldIDModeloOfVehiculoListVehiculo != null) {
                    oldIDModeloOfVehiculoListVehiculo.getVehiculoList().remove(vehiculoListVehiculo);
                    oldIDModeloOfVehiculoListVehiculo = em.merge(oldIDModeloOfVehiculoListVehiculo);
                }
            }
            utx.commit();
        } catch (Exception ex) {
            try {
                utx.rollback();
            } catch (Exception re) {
                throw new RollbackFailureException("An error occurred attempting to roll back the transaction.", re);
            }
            throw ex;
        } finally {
            if (em != null) {
                em.close();
            }
        }
    }

    public void edit(Modelo modelo) throws IllegalOrphanException, NonexistentEntityException, RollbackFailureException, Exception {
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            Modelo persistentModelo = em.find(Modelo.class, modelo.getIDModelo());
            Marca IDMarcaOld = persistentModelo.getIDMarca();
            Marca IDMarcaNew = modelo.getIDMarca();
            List<Vehiculo> vehiculoListOld = persistentModelo.getVehiculoList();
            List<Vehiculo> vehiculoListNew = modelo.getVehiculoList();
            List<String> illegalOrphanMessages = null;
            for (Vehiculo vehiculoListOldVehiculo : vehiculoListOld) {
                if (!vehiculoListNew.contains(vehiculoListOldVehiculo)) {
                    if (illegalOrphanMessages == null) {
                        illegalOrphanMessages = new ArrayList<String>();
                    }
                    illegalOrphanMessages.add("You must retain Vehiculo " + vehiculoListOldVehiculo + " since its IDModelo field is not nullable.");
                }
            }
            if (illegalOrphanMessages != null) {
                throw new IllegalOrphanException(illegalOrphanMessages);
            }
            if (IDMarcaNew != null) {
                IDMarcaNew = em.getReference(IDMarcaNew.getClass(), IDMarcaNew.getIDMarca());
                modelo.setIDMarca(IDMarcaNew);
            }
            List<Vehiculo> attachedVehiculoListNew = new ArrayList<Vehiculo>();
            for (Vehiculo vehiculoListNewVehiculoToAttach : vehiculoListNew) {
                vehiculoListNewVehiculoToAttach = em.getReference(vehiculoListNewVehiculoToAttach.getClass(), vehiculoListNewVehiculoToAttach.getIDVehiculo());
                attachedVehiculoListNew.add(vehiculoListNewVehiculoToAttach);
            }
            vehiculoListNew = attachedVehiculoListNew;
            modelo.setVehiculoList(vehiculoListNew);
            modelo = em.merge(modelo);
            if (IDMarcaOld != null && !IDMarcaOld.equals(IDMarcaNew)) {
                IDMarcaOld.getModeloList().remove(modelo);
                IDMarcaOld = em.merge(IDMarcaOld);
            }
            if (IDMarcaNew != null && !IDMarcaNew.equals(IDMarcaOld)) {
                IDMarcaNew.getModeloList().add(modelo);
                IDMarcaNew = em.merge(IDMarcaNew);
            }
            for (Vehiculo vehiculoListNewVehiculo : vehiculoListNew) {
                if (!vehiculoListOld.contains(vehiculoListNewVehiculo)) {
                    Modelo oldIDModeloOfVehiculoListNewVehiculo = vehiculoListNewVehiculo.getIDModelo();
                    vehiculoListNewVehiculo.setIDModelo(modelo);
                    vehiculoListNewVehiculo = em.merge(vehiculoListNewVehiculo);
                    if (oldIDModeloOfVehiculoListNewVehiculo != null && !oldIDModeloOfVehiculoListNewVehiculo.equals(modelo)) {
                        oldIDModeloOfVehiculoListNewVehiculo.getVehiculoList().remove(vehiculoListNewVehiculo);
                        oldIDModeloOfVehiculoListNewVehiculo = em.merge(oldIDModeloOfVehiculoListNewVehiculo);
                    }
                }
            }
            utx.commit();
        } catch (Exception ex) {
            try {
                utx.rollback();
            } catch (Exception re) {
                throw new RollbackFailureException("An error occurred attempting to roll back the transaction.", re);
            }
            String msg = ex.getLocalizedMessage();
            if (msg == null || msg.length() == 0) {
                Integer id = modelo.getIDModelo();
                if (findModelo(id) == null) {
                    throw new NonexistentEntityException("The modelo with id " + id + " no longer exists.");
                }
            }
            throw ex;
        } finally {
            if (em != null) {
                em.close();
            }
        }
    }

    public void destroy(Integer id) throws IllegalOrphanException, NonexistentEntityException, RollbackFailureException, Exception {
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            Modelo modelo;
            try {
                modelo = em.getReference(Modelo.class, id);
                modelo.getIDModelo();
            } catch (EntityNotFoundException enfe) {
                throw new NonexistentEntityException("The modelo with id " + id + " no longer exists.", enfe);
            }
            List<String> illegalOrphanMessages = null;
            List<Vehiculo> vehiculoListOrphanCheck = modelo.getVehiculoList();
            for (Vehiculo vehiculoListOrphanCheckVehiculo : vehiculoListOrphanCheck) {
                if (illegalOrphanMessages == null) {
                    illegalOrphanMessages = new ArrayList<String>();
                }
                illegalOrphanMessages.add("This Modelo (" + modelo + ") cannot be destroyed since the Vehiculo " + vehiculoListOrphanCheckVehiculo + " in its vehiculoList field has a non-nullable IDModelo field.");
            }
            if (illegalOrphanMessages != null) {
                throw new IllegalOrphanException(illegalOrphanMessages);
            }
            Marca IDMarca = modelo.getIDMarca();
            if (IDMarca != null) {
                IDMarca.getModeloList().remove(modelo);
                IDMarca = em.merge(IDMarca);
            }
            em.remove(modelo);
            utx.commit();
        } catch (Exception ex) {
            try {
                utx.rollback();
            } catch (Exception re) {
                throw new RollbackFailureException("An error occurred attempting to roll back the transaction.", re);
            }
            throw ex;
        } finally {
            if (em != null) {
                em.close();
            }
        }
    }

    public List<Modelo> findModeloEntities() {
        return findModeloEntities(true, -1, -1);
    }

    public List<Modelo> findModeloEntities(int maxResults, int firstResult) {
        return findModeloEntities(false, maxResults, firstResult);
    }

    private List<Modelo> findModeloEntities(boolean all, int maxResults, int firstResult) {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            cq.select(cq.from(Modelo.class));
            Query q = em.createQuery(cq);
            if (!all) {
                q.setMaxResults(maxResults);
                q.setFirstResult(firstResult);
            }
            return q.getResultList();
        } finally {
            em.close();
        }
    }

    public Modelo findModelo(Integer id) {
        EntityManager em = getEntityManager();
        try {
            return em.find(Modelo.class, id);
        } finally {
            em.close();
        }
    }

    public int getModeloCount() {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            Root<Modelo> rt = cq.from(Modelo.class);
            cq.select(em.getCriteriaBuilder().count(rt));
            Query q = em.createQuery(cq);
            return ((Long) q.getSingleResult()).intValue();
        } finally {
            em.close();
        }
    }
    
}
