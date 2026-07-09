/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.upec.controller;

import com.upec.controller.exceptions.IllegalOrphanException;
import com.upec.controller.exceptions.NonexistentEntityException;
import com.upec.controller.exceptions.RollbackFailureException;
import com.upec.model.EstadoTrabajo;
import java.io.Serializable;
import jakarta.persistence.Query;
import jakarta.persistence.EntityNotFoundException;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Root;
import com.upec.model.OrdenServicio;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.transaction.UserTransaction;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author ACER NITRO V15
 */
public class EstadoTrabajoJpaController implements Serializable {

    public EstadoTrabajoJpaController(UserTransaction utx, EntityManagerFactory emf) {
        this.utx = utx;
        this.emf = emf;
    }
    private UserTransaction utx = null;
    private EntityManagerFactory emf = null;

    public EntityManager getEntityManager() {
        return emf.createEntityManager();
    }

    public void create(EstadoTrabajo estadoTrabajo) throws RollbackFailureException, Exception {
        if (estadoTrabajo.getOrdenServicioList() == null) {
            estadoTrabajo.setOrdenServicioList(new ArrayList<OrdenServicio>());
        }
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            List<OrdenServicio> attachedOrdenServicioList = new ArrayList<OrdenServicio>();
            for (OrdenServicio ordenServicioListOrdenServicioToAttach : estadoTrabajo.getOrdenServicioList()) {
                ordenServicioListOrdenServicioToAttach = em.getReference(ordenServicioListOrdenServicioToAttach.getClass(), ordenServicioListOrdenServicioToAttach.getIDOrdenServicio());
                attachedOrdenServicioList.add(ordenServicioListOrdenServicioToAttach);
            }
            estadoTrabajo.setOrdenServicioList(attachedOrdenServicioList);
            em.persist(estadoTrabajo);
            for (OrdenServicio ordenServicioListOrdenServicio : estadoTrabajo.getOrdenServicioList()) {
                EstadoTrabajo oldIDEstadoTrabajoOfOrdenServicioListOrdenServicio = ordenServicioListOrdenServicio.getIDEstadoTrabajo();
                ordenServicioListOrdenServicio.setIDEstadoTrabajo(estadoTrabajo);
                ordenServicioListOrdenServicio = em.merge(ordenServicioListOrdenServicio);
                if (oldIDEstadoTrabajoOfOrdenServicioListOrdenServicio != null) {
                    oldIDEstadoTrabajoOfOrdenServicioListOrdenServicio.getOrdenServicioList().remove(ordenServicioListOrdenServicio);
                    oldIDEstadoTrabajoOfOrdenServicioListOrdenServicio = em.merge(oldIDEstadoTrabajoOfOrdenServicioListOrdenServicio);
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

    public void edit(EstadoTrabajo estadoTrabajo) throws IllegalOrphanException, NonexistentEntityException, RollbackFailureException, Exception {
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            EstadoTrabajo persistentEstadoTrabajo = em.find(EstadoTrabajo.class, estadoTrabajo.getIDEstadoTrabajo());
            List<OrdenServicio> ordenServicioListOld = persistentEstadoTrabajo.getOrdenServicioList();
            List<OrdenServicio> ordenServicioListNew = estadoTrabajo.getOrdenServicioList();
            List<String> illegalOrphanMessages = null;
            for (OrdenServicio ordenServicioListOldOrdenServicio : ordenServicioListOld) {
                if (!ordenServicioListNew.contains(ordenServicioListOldOrdenServicio)) {
                    if (illegalOrphanMessages == null) {
                        illegalOrphanMessages = new ArrayList<String>();
                    }
                    illegalOrphanMessages.add("You must retain OrdenServicio " + ordenServicioListOldOrdenServicio + " since its IDEstadoTrabajo field is not nullable.");
                }
            }
            if (illegalOrphanMessages != null) {
                throw new IllegalOrphanException(illegalOrphanMessages);
            }
            List<OrdenServicio> attachedOrdenServicioListNew = new ArrayList<OrdenServicio>();
            for (OrdenServicio ordenServicioListNewOrdenServicioToAttach : ordenServicioListNew) {
                ordenServicioListNewOrdenServicioToAttach = em.getReference(ordenServicioListNewOrdenServicioToAttach.getClass(), ordenServicioListNewOrdenServicioToAttach.getIDOrdenServicio());
                attachedOrdenServicioListNew.add(ordenServicioListNewOrdenServicioToAttach);
            }
            ordenServicioListNew = attachedOrdenServicioListNew;
            estadoTrabajo.setOrdenServicioList(ordenServicioListNew);
            estadoTrabajo = em.merge(estadoTrabajo);
            for (OrdenServicio ordenServicioListNewOrdenServicio : ordenServicioListNew) {
                if (!ordenServicioListOld.contains(ordenServicioListNewOrdenServicio)) {
                    EstadoTrabajo oldIDEstadoTrabajoOfOrdenServicioListNewOrdenServicio = ordenServicioListNewOrdenServicio.getIDEstadoTrabajo();
                    ordenServicioListNewOrdenServicio.setIDEstadoTrabajo(estadoTrabajo);
                    ordenServicioListNewOrdenServicio = em.merge(ordenServicioListNewOrdenServicio);
                    if (oldIDEstadoTrabajoOfOrdenServicioListNewOrdenServicio != null && !oldIDEstadoTrabajoOfOrdenServicioListNewOrdenServicio.equals(estadoTrabajo)) {
                        oldIDEstadoTrabajoOfOrdenServicioListNewOrdenServicio.getOrdenServicioList().remove(ordenServicioListNewOrdenServicio);
                        oldIDEstadoTrabajoOfOrdenServicioListNewOrdenServicio = em.merge(oldIDEstadoTrabajoOfOrdenServicioListNewOrdenServicio);
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
                Integer id = estadoTrabajo.getIDEstadoTrabajo();
                if (findEstadoTrabajo(id) == null) {
                    throw new NonexistentEntityException("The estadoTrabajo with id " + id + " no longer exists.");
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
            EstadoTrabajo estadoTrabajo;
            try {
                estadoTrabajo = em.getReference(EstadoTrabajo.class, id);
                estadoTrabajo.getIDEstadoTrabajo();
            } catch (EntityNotFoundException enfe) {
                throw new NonexistentEntityException("The estadoTrabajo with id " + id + " no longer exists.", enfe);
            }
            List<String> illegalOrphanMessages = null;
            List<OrdenServicio> ordenServicioListOrphanCheck = estadoTrabajo.getOrdenServicioList();
            for (OrdenServicio ordenServicioListOrphanCheckOrdenServicio : ordenServicioListOrphanCheck) {
                if (illegalOrphanMessages == null) {
                    illegalOrphanMessages = new ArrayList<String>();
                }
                illegalOrphanMessages.add("This EstadoTrabajo (" + estadoTrabajo + ") cannot be destroyed since the OrdenServicio " + ordenServicioListOrphanCheckOrdenServicio + " in its ordenServicioList field has a non-nullable IDEstadoTrabajo field.");
            }
            if (illegalOrphanMessages != null) {
                throw new IllegalOrphanException(illegalOrphanMessages);
            }
            em.remove(estadoTrabajo);
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

    public List<EstadoTrabajo> findEstadoTrabajoEntities() {
        return findEstadoTrabajoEntities(true, -1, -1);
    }

    public List<EstadoTrabajo> findEstadoTrabajoEntities(int maxResults, int firstResult) {
        return findEstadoTrabajoEntities(false, maxResults, firstResult);
    }

    private List<EstadoTrabajo> findEstadoTrabajoEntities(boolean all, int maxResults, int firstResult) {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            cq.select(cq.from(EstadoTrabajo.class));
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

    public EstadoTrabajo findEstadoTrabajo(Integer id) {
        EntityManager em = getEntityManager();
        try {
            return em.find(EstadoTrabajo.class, id);
        } finally {
            em.close();
        }
    }

    public int getEstadoTrabajoCount() {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            Root<EstadoTrabajo> rt = cq.from(EstadoTrabajo.class);
            cq.select(em.getCriteriaBuilder().count(rt));
            Query q = em.createQuery(cq);
            return ((Long) q.getSingleResult()).intValue();
        } finally {
            em.close();
        }
    }
    
}
