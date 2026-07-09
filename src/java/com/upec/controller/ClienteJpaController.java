/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.upec.controller;

import com.upec.controller.exceptions.IllegalOrphanException;
import com.upec.controller.exceptions.NonexistentEntityException;
import com.upec.controller.exceptions.RollbackFailureException;
import com.upec.model.Cliente;
import java.io.Serializable;
import jakarta.persistence.Query;
import jakarta.persistence.EntityNotFoundException;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Root;
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
public class ClienteJpaController implements Serializable {

    public ClienteJpaController(UserTransaction utx, EntityManagerFactory emf) {
        this.utx = utx;
        this.emf = emf;
    }
    private UserTransaction utx = null;
    private EntityManagerFactory emf = null;

    public EntityManager getEntityManager() {
        return emf.createEntityManager();
    }

    public void create(Cliente cliente) throws RollbackFailureException, Exception {
        if (cliente.getVehiculoList() == null) {
            cliente.setVehiculoList(new ArrayList<Vehiculo>());
        }
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            List<Vehiculo> attachedVehiculoList = new ArrayList<Vehiculo>();
            for (Vehiculo vehiculoListVehiculoToAttach : cliente.getVehiculoList()) {
                vehiculoListVehiculoToAttach = em.getReference(vehiculoListVehiculoToAttach.getClass(), vehiculoListVehiculoToAttach.getIDVehiculo());
                attachedVehiculoList.add(vehiculoListVehiculoToAttach);
            }
            cliente.setVehiculoList(attachedVehiculoList);
            em.persist(cliente);
            for (Vehiculo vehiculoListVehiculo : cliente.getVehiculoList()) {
                Cliente oldIDClienteOfVehiculoListVehiculo = vehiculoListVehiculo.getIDCliente();
                vehiculoListVehiculo.setIDCliente(cliente);
                vehiculoListVehiculo = em.merge(vehiculoListVehiculo);
                if (oldIDClienteOfVehiculoListVehiculo != null) {
                    oldIDClienteOfVehiculoListVehiculo.getVehiculoList().remove(vehiculoListVehiculo);
                    oldIDClienteOfVehiculoListVehiculo = em.merge(oldIDClienteOfVehiculoListVehiculo);
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

    public void edit(Cliente cliente) throws IllegalOrphanException, NonexistentEntityException, RollbackFailureException, Exception {
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            Cliente persistentCliente = em.find(Cliente.class, cliente.getIDCliente());
            List<Vehiculo> vehiculoListOld = persistentCliente.getVehiculoList();
            List<Vehiculo> vehiculoListNew = cliente.getVehiculoList();
            List<String> illegalOrphanMessages = null;
            for (Vehiculo vehiculoListOldVehiculo : vehiculoListOld) {
                if (!vehiculoListNew.contains(vehiculoListOldVehiculo)) {
                    if (illegalOrphanMessages == null) {
                        illegalOrphanMessages = new ArrayList<String>();
                    }
                    illegalOrphanMessages.add("You must retain Vehiculo " + vehiculoListOldVehiculo + " since its IDCliente field is not nullable.");
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
            cliente.setVehiculoList(vehiculoListNew);
            cliente = em.merge(cliente);
            for (Vehiculo vehiculoListNewVehiculo : vehiculoListNew) {
                if (!vehiculoListOld.contains(vehiculoListNewVehiculo)) {
                    Cliente oldIDClienteOfVehiculoListNewVehiculo = vehiculoListNewVehiculo.getIDCliente();
                    vehiculoListNewVehiculo.setIDCliente(cliente);
                    vehiculoListNewVehiculo = em.merge(vehiculoListNewVehiculo);
                    if (oldIDClienteOfVehiculoListNewVehiculo != null && !oldIDClienteOfVehiculoListNewVehiculo.equals(cliente)) {
                        oldIDClienteOfVehiculoListNewVehiculo.getVehiculoList().remove(vehiculoListNewVehiculo);
                        oldIDClienteOfVehiculoListNewVehiculo = em.merge(oldIDClienteOfVehiculoListNewVehiculo);
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
                Integer id = cliente.getIDCliente();
                if (findCliente(id) == null) {
                    throw new NonexistentEntityException("The cliente with id " + id + " no longer exists.");
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
            Cliente cliente;
            try {
                cliente = em.getReference(Cliente.class, id);
                cliente.getIDCliente();
            } catch (EntityNotFoundException enfe) {
                throw new NonexistentEntityException("The cliente with id " + id + " no longer exists.", enfe);
            }
            List<String> illegalOrphanMessages = null;
            List<Vehiculo> vehiculoListOrphanCheck = cliente.getVehiculoList();
            for (Vehiculo vehiculoListOrphanCheckVehiculo : vehiculoListOrphanCheck) {
                if (illegalOrphanMessages == null) {
                    illegalOrphanMessages = new ArrayList<String>();
                }
                illegalOrphanMessages.add("This Cliente (" + cliente + ") cannot be destroyed since the Vehiculo " + vehiculoListOrphanCheckVehiculo + " in its vehiculoList field has a non-nullable IDCliente field.");
            }
            if (illegalOrphanMessages != null) {
                throw new IllegalOrphanException(illegalOrphanMessages);
            }
            em.remove(cliente);
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

    public List<Cliente> findClienteEntities() {
        return findClienteEntities(true, -1, -1);
    }

    public List<Cliente> findClienteEntities(int maxResults, int firstResult) {
        return findClienteEntities(false, maxResults, firstResult);
    }

    private List<Cliente> findClienteEntities(boolean all, int maxResults, int firstResult) {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            cq.select(cq.from(Cliente.class));
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

    public Cliente findCliente(Integer id) {
        EntityManager em = getEntityManager();
        try {
            return em.find(Cliente.class, id);
        } finally {
            em.close();
        }
    }

    public int getClienteCount() {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            Root<Cliente> rt = cq.from(Cliente.class);
            cq.select(em.getCriteriaBuilder().count(rt));
            Query q = em.createQuery(cq);
            return ((Long) q.getSingleResult()).intValue();
        } finally {
            em.close();
        }
    }
    
}
