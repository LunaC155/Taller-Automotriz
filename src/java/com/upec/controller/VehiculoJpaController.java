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
import com.upec.model.Cliente;
import com.upec.model.Marca;
import com.upec.model.Modelo;
import com.upec.model.OrdenServicio;
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
public class VehiculoJpaController implements Serializable {

    public VehiculoJpaController(UserTransaction utx, EntityManagerFactory emf) {
        this.utx = utx;
        this.emf = emf;
    }
    private UserTransaction utx = null;
    private EntityManagerFactory emf = null;

    public EntityManager getEntityManager() {
        return emf.createEntityManager();
    }

    public void create(Vehiculo vehiculo) throws RollbackFailureException, Exception {
        if (vehiculo.getOrdenServicioList() == null) {
            vehiculo.setOrdenServicioList(new ArrayList<OrdenServicio>());
        }
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            Cliente IDCliente = vehiculo.getIDCliente();
            if (IDCliente != null) {
                IDCliente = em.getReference(IDCliente.getClass(), IDCliente.getIDCliente());
                vehiculo.setIDCliente(IDCliente);
            }
            Marca IDMarca = vehiculo.getIDMarca();
            if (IDMarca != null) {
                IDMarca = em.getReference(IDMarca.getClass(), IDMarca.getIDMarca());
                vehiculo.setIDMarca(IDMarca);
            }
            Modelo IDModelo = vehiculo.getIDModelo();
            if (IDModelo != null) {
                IDModelo = em.getReference(IDModelo.getClass(), IDModelo.getIDModelo());
                vehiculo.setIDModelo(IDModelo);
            }
            List<OrdenServicio> attachedOrdenServicioList = new ArrayList<OrdenServicio>();
            for (OrdenServicio ordenServicioListOrdenServicioToAttach : vehiculo.getOrdenServicioList()) {
                ordenServicioListOrdenServicioToAttach = em.getReference(ordenServicioListOrdenServicioToAttach.getClass(), ordenServicioListOrdenServicioToAttach.getIDOrdenServicio());
                attachedOrdenServicioList.add(ordenServicioListOrdenServicioToAttach);
            }
            vehiculo.setOrdenServicioList(attachedOrdenServicioList);
            em.persist(vehiculo);
            if (IDCliente != null) {
                IDCliente.getVehiculoList().add(vehiculo);
                IDCliente = em.merge(IDCliente);
            }
            if (IDMarca != null) {
                IDMarca.getVehiculoList().add(vehiculo);
                IDMarca = em.merge(IDMarca);
            }
            if (IDModelo != null) {
                IDModelo.getVehiculoList().add(vehiculo);
                IDModelo = em.merge(IDModelo);
            }
            for (OrdenServicio ordenServicioListOrdenServicio : vehiculo.getOrdenServicioList()) {
                Vehiculo oldIDVehiculoOfOrdenServicioListOrdenServicio = ordenServicioListOrdenServicio.getIDVehiculo();
                ordenServicioListOrdenServicio.setIDVehiculo(vehiculo);
                ordenServicioListOrdenServicio = em.merge(ordenServicioListOrdenServicio);
                if (oldIDVehiculoOfOrdenServicioListOrdenServicio != null) {
                    oldIDVehiculoOfOrdenServicioListOrdenServicio.getOrdenServicioList().remove(ordenServicioListOrdenServicio);
                    oldIDVehiculoOfOrdenServicioListOrdenServicio = em.merge(oldIDVehiculoOfOrdenServicioListOrdenServicio);
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

    public void edit(Vehiculo vehiculo) throws IllegalOrphanException, NonexistentEntityException, RollbackFailureException, Exception {
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            Vehiculo persistentVehiculo = em.find(Vehiculo.class, vehiculo.getIDVehiculo());
            Cliente IDClienteOld = persistentVehiculo.getIDCliente();
            Cliente IDClienteNew = vehiculo.getIDCliente();
            Marca IDMarcaOld = persistentVehiculo.getIDMarca();
            Marca IDMarcaNew = vehiculo.getIDMarca();
            Modelo IDModeloOld = persistentVehiculo.getIDModelo();
            Modelo IDModeloNew = vehiculo.getIDModelo();
            List<OrdenServicio> ordenServicioListOld = persistentVehiculo.getOrdenServicioList();
            List<OrdenServicio> ordenServicioListNew = vehiculo.getOrdenServicioList();
            List<String> illegalOrphanMessages = null;
            for (OrdenServicio ordenServicioListOldOrdenServicio : ordenServicioListOld) {
                if (!ordenServicioListNew.contains(ordenServicioListOldOrdenServicio)) {
                    if (illegalOrphanMessages == null) {
                        illegalOrphanMessages = new ArrayList<String>();
                    }
                    illegalOrphanMessages.add("You must retain OrdenServicio " + ordenServicioListOldOrdenServicio + " since its IDVehiculo field is not nullable.");
                }
            }
            if (illegalOrphanMessages != null) {
                throw new IllegalOrphanException(illegalOrphanMessages);
            }
            if (IDClienteNew != null) {
                IDClienteNew = em.getReference(IDClienteNew.getClass(), IDClienteNew.getIDCliente());
                vehiculo.setIDCliente(IDClienteNew);
            }
            if (IDMarcaNew != null) {
                IDMarcaNew = em.getReference(IDMarcaNew.getClass(), IDMarcaNew.getIDMarca());
                vehiculo.setIDMarca(IDMarcaNew);
            }
            if (IDModeloNew != null) {
                IDModeloNew = em.getReference(IDModeloNew.getClass(), IDModeloNew.getIDModelo());
                vehiculo.setIDModelo(IDModeloNew);
            }
            List<OrdenServicio> attachedOrdenServicioListNew = new ArrayList<OrdenServicio>();
            for (OrdenServicio ordenServicioListNewOrdenServicioToAttach : ordenServicioListNew) {
                ordenServicioListNewOrdenServicioToAttach = em.getReference(ordenServicioListNewOrdenServicioToAttach.getClass(), ordenServicioListNewOrdenServicioToAttach.getIDOrdenServicio());
                attachedOrdenServicioListNew.add(ordenServicioListNewOrdenServicioToAttach);
            }
            ordenServicioListNew = attachedOrdenServicioListNew;
            vehiculo.setOrdenServicioList(ordenServicioListNew);
            vehiculo = em.merge(vehiculo);
            if (IDClienteOld != null && !IDClienteOld.equals(IDClienteNew)) {
                IDClienteOld.getVehiculoList().remove(vehiculo);
                IDClienteOld = em.merge(IDClienteOld);
            }
            if (IDClienteNew != null && !IDClienteNew.equals(IDClienteOld)) {
                IDClienteNew.getVehiculoList().add(vehiculo);
                IDClienteNew = em.merge(IDClienteNew);
            }
            if (IDMarcaOld != null && !IDMarcaOld.equals(IDMarcaNew)) {
                IDMarcaOld.getVehiculoList().remove(vehiculo);
                IDMarcaOld = em.merge(IDMarcaOld);
            }
            if (IDMarcaNew != null && !IDMarcaNew.equals(IDMarcaOld)) {
                IDMarcaNew.getVehiculoList().add(vehiculo);
                IDMarcaNew = em.merge(IDMarcaNew);
            }
            if (IDModeloOld != null && !IDModeloOld.equals(IDModeloNew)) {
                IDModeloOld.getVehiculoList().remove(vehiculo);
                IDModeloOld = em.merge(IDModeloOld);
            }
            if (IDModeloNew != null && !IDModeloNew.equals(IDModeloOld)) {
                IDModeloNew.getVehiculoList().add(vehiculo);
                IDModeloNew = em.merge(IDModeloNew);
            }
            for (OrdenServicio ordenServicioListNewOrdenServicio : ordenServicioListNew) {
                if (!ordenServicioListOld.contains(ordenServicioListNewOrdenServicio)) {
                    Vehiculo oldIDVehiculoOfOrdenServicioListNewOrdenServicio = ordenServicioListNewOrdenServicio.getIDVehiculo();
                    ordenServicioListNewOrdenServicio.setIDVehiculo(vehiculo);
                    ordenServicioListNewOrdenServicio = em.merge(ordenServicioListNewOrdenServicio);
                    if (oldIDVehiculoOfOrdenServicioListNewOrdenServicio != null && !oldIDVehiculoOfOrdenServicioListNewOrdenServicio.equals(vehiculo)) {
                        oldIDVehiculoOfOrdenServicioListNewOrdenServicio.getOrdenServicioList().remove(ordenServicioListNewOrdenServicio);
                        oldIDVehiculoOfOrdenServicioListNewOrdenServicio = em.merge(oldIDVehiculoOfOrdenServicioListNewOrdenServicio);
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
                Integer id = vehiculo.getIDVehiculo();
                if (findVehiculo(id) == null) {
                    throw new NonexistentEntityException("The vehiculo with id " + id + " no longer exists.");
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
            Vehiculo vehiculo;
            try {
                vehiculo = em.getReference(Vehiculo.class, id);
                vehiculo.getIDVehiculo();
            } catch (EntityNotFoundException enfe) {
                throw new NonexistentEntityException("The vehiculo with id " + id + " no longer exists.", enfe);
            }
            List<String> illegalOrphanMessages = null;
            List<OrdenServicio> ordenServicioListOrphanCheck = vehiculo.getOrdenServicioList();
            for (OrdenServicio ordenServicioListOrphanCheckOrdenServicio : ordenServicioListOrphanCheck) {
                if (illegalOrphanMessages == null) {
                    illegalOrphanMessages = new ArrayList<String>();
                }
                illegalOrphanMessages.add("This Vehiculo (" + vehiculo + ") cannot be destroyed since the OrdenServicio " + ordenServicioListOrphanCheckOrdenServicio + " in its ordenServicioList field has a non-nullable IDVehiculo field.");
            }
            if (illegalOrphanMessages != null) {
                throw new IllegalOrphanException(illegalOrphanMessages);
            }
            Cliente IDCliente = vehiculo.getIDCliente();
            if (IDCliente != null) {
                IDCliente.getVehiculoList().remove(vehiculo);
                IDCliente = em.merge(IDCliente);
            }
            Marca IDMarca = vehiculo.getIDMarca();
            if (IDMarca != null) {
                IDMarca.getVehiculoList().remove(vehiculo);
                IDMarca = em.merge(IDMarca);
            }
            Modelo IDModelo = vehiculo.getIDModelo();
            if (IDModelo != null) {
                IDModelo.getVehiculoList().remove(vehiculo);
                IDModelo = em.merge(IDModelo);
            }
            em.remove(vehiculo);
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

    public List<Vehiculo> findVehiculoEntities() {
        return findVehiculoEntities(true, -1, -1);
    }

    public List<Vehiculo> findVehiculoEntities(int maxResults, int firstResult) {
        return findVehiculoEntities(false, maxResults, firstResult);
    }

    private List<Vehiculo> findVehiculoEntities(boolean all, int maxResults, int firstResult) {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            cq.select(cq.from(Vehiculo.class));
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

    public Vehiculo findVehiculo(Integer id) {
        EntityManager em = getEntityManager();
        try {
            return em.find(Vehiculo.class, id);
        } finally {
            em.close();
        }
    }

    public int getVehiculoCount() {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            Root<Vehiculo> rt = cq.from(Vehiculo.class);
            cq.select(em.getCriteriaBuilder().count(rt));
            Query q = em.createQuery(cq);
            return ((Long) q.getSingleResult()).intValue();
        } finally {
            em.close();
        }
    }
    
}
