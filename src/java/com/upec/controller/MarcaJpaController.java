/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.upec.controller;

import com.upec.controller.exceptions.IllegalOrphanException;
import com.upec.controller.exceptions.NonexistentEntityException;
import com.upec.controller.exceptions.RollbackFailureException;
import com.upec.model.Marca;
import java.io.Serializable;
import jakarta.persistence.Query;
import jakarta.persistence.EntityNotFoundException;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Root;
import com.upec.model.Vehiculo;
import java.util.ArrayList;
import java.util.List;
import com.upec.model.Modelo;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.transaction.UserTransaction;

/**
 *
 * @author ACER NITRO V15
 */
public class MarcaJpaController implements Serializable {

    public MarcaJpaController(UserTransaction utx, EntityManagerFactory emf) {
        this.utx = utx;
        this.emf = emf;
    }
    private UserTransaction utx = null;
    private EntityManagerFactory emf = null;

    public EntityManager getEntityManager() {
        return emf.createEntityManager();
    }

    public void create(Marca marca) throws RollbackFailureException, Exception {
        if (marca.getVehiculoList() == null) {
            marca.setVehiculoList(new ArrayList<Vehiculo>());
        }
        if (marca.getModeloList() == null) {
            marca.setModeloList(new ArrayList<Modelo>());
        }
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            List<Vehiculo> attachedVehiculoList = new ArrayList<Vehiculo>();
            for (Vehiculo vehiculoListVehiculoToAttach : marca.getVehiculoList()) {
                vehiculoListVehiculoToAttach = em.getReference(vehiculoListVehiculoToAttach.getClass(), vehiculoListVehiculoToAttach.getIDVehiculo());
                attachedVehiculoList.add(vehiculoListVehiculoToAttach);
            }
            marca.setVehiculoList(attachedVehiculoList);
            List<Modelo> attachedModeloList = new ArrayList<Modelo>();
            for (Modelo modeloListModeloToAttach : marca.getModeloList()) {
                modeloListModeloToAttach = em.getReference(modeloListModeloToAttach.getClass(), modeloListModeloToAttach.getIDModelo());
                attachedModeloList.add(modeloListModeloToAttach);
            }
            marca.setModeloList(attachedModeloList);
            em.persist(marca);
            for (Vehiculo vehiculoListVehiculo : marca.getVehiculoList()) {
                Marca oldIDMarcaOfVehiculoListVehiculo = vehiculoListVehiculo.getIDMarca();
                vehiculoListVehiculo.setIDMarca(marca);
                vehiculoListVehiculo = em.merge(vehiculoListVehiculo);
                if (oldIDMarcaOfVehiculoListVehiculo != null) {
                    oldIDMarcaOfVehiculoListVehiculo.getVehiculoList().remove(vehiculoListVehiculo);
                    oldIDMarcaOfVehiculoListVehiculo = em.merge(oldIDMarcaOfVehiculoListVehiculo);
                }
            }
            for (Modelo modeloListModelo : marca.getModeloList()) {
                Marca oldIDMarcaOfModeloListModelo = modeloListModelo.getIDMarca();
                modeloListModelo.setIDMarca(marca);
                modeloListModelo = em.merge(modeloListModelo);
                if (oldIDMarcaOfModeloListModelo != null) {
                    oldIDMarcaOfModeloListModelo.getModeloList().remove(modeloListModelo);
                    oldIDMarcaOfModeloListModelo = em.merge(oldIDMarcaOfModeloListModelo);
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

    public void edit(Marca marca) throws IllegalOrphanException, NonexistentEntityException, RollbackFailureException, Exception {
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            Marca persistentMarca = em.find(Marca.class, marca.getIDMarca());
            List<Vehiculo> vehiculoListOld = persistentMarca.getVehiculoList();
            List<Vehiculo> vehiculoListNew = marca.getVehiculoList();
            List<Modelo> modeloListOld = persistentMarca.getModeloList();
            List<Modelo> modeloListNew = marca.getModeloList();
            List<String> illegalOrphanMessages = null;
            for (Vehiculo vehiculoListOldVehiculo : vehiculoListOld) {
                if (!vehiculoListNew.contains(vehiculoListOldVehiculo)) {
                    if (illegalOrphanMessages == null) {
                        illegalOrphanMessages = new ArrayList<String>();
                    }
                    illegalOrphanMessages.add("You must retain Vehiculo " + vehiculoListOldVehiculo + " since its IDMarca field is not nullable.");
                }
            }
            for (Modelo modeloListOldModelo : modeloListOld) {
                if (!modeloListNew.contains(modeloListOldModelo)) {
                    if (illegalOrphanMessages == null) {
                        illegalOrphanMessages = new ArrayList<String>();
                    }
                    illegalOrphanMessages.add("You must retain Modelo " + modeloListOldModelo + " since its IDMarca field is not nullable.");
                }
            }
            if (illegalOrphanMessages != null) {
                throw new IllegalOrphanException(illegalOrphanMessages);
            }
            List<Vehiculo> attachedVehiculoListNew = new ArrayList<Vehiculo>();
            for (Vehiculo vehiculoListNewVehiculoToAttach : vehiculoListNew) {
                vehiculoListNewVehiculoToAttach = em.getReference(vehiculoListNewVehiculoToAttach.getClass(), vehiculoListNewVehiculoToAttach.getIDVehiculo());
                attachedVehiculoListNew.add(vehiculoListNewVehiculoToAttach);
            }
            vehiculoListNew = attachedVehiculoListNew;
            marca.setVehiculoList(vehiculoListNew);
            List<Modelo> attachedModeloListNew = new ArrayList<Modelo>();
            for (Modelo modeloListNewModeloToAttach : modeloListNew) {
                modeloListNewModeloToAttach = em.getReference(modeloListNewModeloToAttach.getClass(), modeloListNewModeloToAttach.getIDModelo());
                attachedModeloListNew.add(modeloListNewModeloToAttach);
            }
            modeloListNew = attachedModeloListNew;
            marca.setModeloList(modeloListNew);
            marca = em.merge(marca);
            for (Vehiculo vehiculoListNewVehiculo : vehiculoListNew) {
                if (!vehiculoListOld.contains(vehiculoListNewVehiculo)) {
                    Marca oldIDMarcaOfVehiculoListNewVehiculo = vehiculoListNewVehiculo.getIDMarca();
                    vehiculoListNewVehiculo.setIDMarca(marca);
                    vehiculoListNewVehiculo = em.merge(vehiculoListNewVehiculo);
                    if (oldIDMarcaOfVehiculoListNewVehiculo != null && !oldIDMarcaOfVehiculoListNewVehiculo.equals(marca)) {
                        oldIDMarcaOfVehiculoListNewVehiculo.getVehiculoList().remove(vehiculoListNewVehiculo);
                        oldIDMarcaOfVehiculoListNewVehiculo = em.merge(oldIDMarcaOfVehiculoListNewVehiculo);
                    }
                }
            }
            for (Modelo modeloListNewModelo : modeloListNew) {
                if (!modeloListOld.contains(modeloListNewModelo)) {
                    Marca oldIDMarcaOfModeloListNewModelo = modeloListNewModelo.getIDMarca();
                    modeloListNewModelo.setIDMarca(marca);
                    modeloListNewModelo = em.merge(modeloListNewModelo);
                    if (oldIDMarcaOfModeloListNewModelo != null && !oldIDMarcaOfModeloListNewModelo.equals(marca)) {
                        oldIDMarcaOfModeloListNewModelo.getModeloList().remove(modeloListNewModelo);
                        oldIDMarcaOfModeloListNewModelo = em.merge(oldIDMarcaOfModeloListNewModelo);
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
                Integer id = marca.getIDMarca();
                if (findMarca(id) == null) {
                    throw new NonexistentEntityException("The marca with id " + id + " no longer exists.");
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
            Marca marca;
            try {
                marca = em.getReference(Marca.class, id);
                marca.getIDMarca();
            } catch (EntityNotFoundException enfe) {
                throw new NonexistentEntityException("The marca with id " + id + " no longer exists.", enfe);
            }
            List<String> illegalOrphanMessages = null;
            List<Vehiculo> vehiculoListOrphanCheck = marca.getVehiculoList();
            for (Vehiculo vehiculoListOrphanCheckVehiculo : vehiculoListOrphanCheck) {
                if (illegalOrphanMessages == null) {
                    illegalOrphanMessages = new ArrayList<String>();
                }
                illegalOrphanMessages.add("This Marca (" + marca + ") cannot be destroyed since the Vehiculo " + vehiculoListOrphanCheckVehiculo + " in its vehiculoList field has a non-nullable IDMarca field.");
            }
            List<Modelo> modeloListOrphanCheck = marca.getModeloList();
            for (Modelo modeloListOrphanCheckModelo : modeloListOrphanCheck) {
                if (illegalOrphanMessages == null) {
                    illegalOrphanMessages = new ArrayList<String>();
                }
                illegalOrphanMessages.add("This Marca (" + marca + ") cannot be destroyed since the Modelo " + modeloListOrphanCheckModelo + " in its modeloList field has a non-nullable IDMarca field.");
            }
            if (illegalOrphanMessages != null) {
                throw new IllegalOrphanException(illegalOrphanMessages);
            }
            em.remove(marca);
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

    public List<Marca> findMarcaEntities() {
        return findMarcaEntities(true, -1, -1);
    }

    public List<Marca> findMarcaEntities(int maxResults, int firstResult) {
        return findMarcaEntities(false, maxResults, firstResult);
    }

    private List<Marca> findMarcaEntities(boolean all, int maxResults, int firstResult) {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            cq.select(cq.from(Marca.class));
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

    public Marca findMarca(Integer id) {
        EntityManager em = getEntityManager();
        try {
            return em.find(Marca.class, id);
        } finally {
            em.close();
        }
    }

    public int getMarcaCount() {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            Root<Marca> rt = cq.from(Marca.class);
            cq.select(em.getCriteriaBuilder().count(rt));
            Query q = em.createQuery(cq);
            return ((Long) q.getSingleResult()).intValue();
        } finally {
            em.close();
        }
    }
    
}
