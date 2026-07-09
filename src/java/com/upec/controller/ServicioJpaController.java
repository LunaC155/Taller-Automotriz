/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.upec.controller;

import com.upec.controller.exceptions.NonexistentEntityException;
import com.upec.controller.exceptions.RollbackFailureException;
import java.io.Serializable;
import jakarta.persistence.Query;
import jakarta.persistence.EntityNotFoundException;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Root;
import com.upec.model.DetalleFactura;
import com.upec.model.Servicio;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.transaction.UserTransaction;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author ACER NITRO V15
 */
public class ServicioJpaController implements Serializable {

    public ServicioJpaController(UserTransaction utx, EntityManagerFactory emf) {
        this.utx = utx;
        this.emf = emf;
    }
    private UserTransaction utx = null;
    private EntityManagerFactory emf = null;

    public EntityManager getEntityManager() {
        return emf.createEntityManager();
    }

    public void create(Servicio servicio) throws RollbackFailureException, Exception {
        if (servicio.getDetalleFacturaList() == null) {
            servicio.setDetalleFacturaList(new ArrayList<DetalleFactura>());
        }
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            List<DetalleFactura> attachedDetalleFacturaList = new ArrayList<DetalleFactura>();
            for (DetalleFactura detalleFacturaListDetalleFacturaToAttach : servicio.getDetalleFacturaList()) {
                detalleFacturaListDetalleFacturaToAttach = em.getReference(detalleFacturaListDetalleFacturaToAttach.getClass(), detalleFacturaListDetalleFacturaToAttach.getIDDetalleFactura());
                attachedDetalleFacturaList.add(detalleFacturaListDetalleFacturaToAttach);
            }
            servicio.setDetalleFacturaList(attachedDetalleFacturaList);
            em.persist(servicio);
            for (DetalleFactura detalleFacturaListDetalleFactura : servicio.getDetalleFacturaList()) {
                Servicio oldIDServicioOfDetalleFacturaListDetalleFactura = detalleFacturaListDetalleFactura.getIDServicio();
                detalleFacturaListDetalleFactura.setIDServicio(servicio);
                detalleFacturaListDetalleFactura = em.merge(detalleFacturaListDetalleFactura);
                if (oldIDServicioOfDetalleFacturaListDetalleFactura != null) {
                    oldIDServicioOfDetalleFacturaListDetalleFactura.getDetalleFacturaList().remove(detalleFacturaListDetalleFactura);
                    oldIDServicioOfDetalleFacturaListDetalleFactura = em.merge(oldIDServicioOfDetalleFacturaListDetalleFactura);
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

    public void edit(Servicio servicio) throws NonexistentEntityException, RollbackFailureException, Exception {
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            Servicio persistentServicio = em.find(Servicio.class, servicio.getIDServicio());
            List<DetalleFactura> detalleFacturaListOld = persistentServicio.getDetalleFacturaList();
            List<DetalleFactura> detalleFacturaListNew = servicio.getDetalleFacturaList();
            List<DetalleFactura> attachedDetalleFacturaListNew = new ArrayList<DetalleFactura>();
            for (DetalleFactura detalleFacturaListNewDetalleFacturaToAttach : detalleFacturaListNew) {
                detalleFacturaListNewDetalleFacturaToAttach = em.getReference(detalleFacturaListNewDetalleFacturaToAttach.getClass(), detalleFacturaListNewDetalleFacturaToAttach.getIDDetalleFactura());
                attachedDetalleFacturaListNew.add(detalleFacturaListNewDetalleFacturaToAttach);
            }
            detalleFacturaListNew = attachedDetalleFacturaListNew;
            servicio.setDetalleFacturaList(detalleFacturaListNew);
            servicio = em.merge(servicio);
            for (DetalleFactura detalleFacturaListOldDetalleFactura : detalleFacturaListOld) {
                if (!detalleFacturaListNew.contains(detalleFacturaListOldDetalleFactura)) {
                    detalleFacturaListOldDetalleFactura.setIDServicio(null);
                    detalleFacturaListOldDetalleFactura = em.merge(detalleFacturaListOldDetalleFactura);
                }
            }
            for (DetalleFactura detalleFacturaListNewDetalleFactura : detalleFacturaListNew) {
                if (!detalleFacturaListOld.contains(detalleFacturaListNewDetalleFactura)) {
                    Servicio oldIDServicioOfDetalleFacturaListNewDetalleFactura = detalleFacturaListNewDetalleFactura.getIDServicio();
                    detalleFacturaListNewDetalleFactura.setIDServicio(servicio);
                    detalleFacturaListNewDetalleFactura = em.merge(detalleFacturaListNewDetalleFactura);
                    if (oldIDServicioOfDetalleFacturaListNewDetalleFactura != null && !oldIDServicioOfDetalleFacturaListNewDetalleFactura.equals(servicio)) {
                        oldIDServicioOfDetalleFacturaListNewDetalleFactura.getDetalleFacturaList().remove(detalleFacturaListNewDetalleFactura);
                        oldIDServicioOfDetalleFacturaListNewDetalleFactura = em.merge(oldIDServicioOfDetalleFacturaListNewDetalleFactura);
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
                Integer id = servicio.getIDServicio();
                if (findServicio(id) == null) {
                    throw new NonexistentEntityException("The servicio with id " + id + " no longer exists.");
                }
            }
            throw ex;
        } finally {
            if (em != null) {
                em.close();
            }
        }
    }

    public void destroy(Integer id) throws NonexistentEntityException, RollbackFailureException, Exception {
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            Servicio servicio;
            try {
                servicio = em.getReference(Servicio.class, id);
                servicio.getIDServicio();
            } catch (EntityNotFoundException enfe) {
                throw new NonexistentEntityException("The servicio with id " + id + " no longer exists.", enfe);
            }
            List<DetalleFactura> detalleFacturaList = servicio.getDetalleFacturaList();
            for (DetalleFactura detalleFacturaListDetalleFactura : detalleFacturaList) {
                detalleFacturaListDetalleFactura.setIDServicio(null);
                detalleFacturaListDetalleFactura = em.merge(detalleFacturaListDetalleFactura);
            }
            em.remove(servicio);
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

    public List<Servicio> findServicioEntities() {
        return findServicioEntities(true, -1, -1);
    }

    public List<Servicio> findServicioEntities(int maxResults, int firstResult) {
        return findServicioEntities(false, maxResults, firstResult);
    }

    private List<Servicio> findServicioEntities(boolean all, int maxResults, int firstResult) {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            cq.select(cq.from(Servicio.class));
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

    public Servicio findServicio(Integer id) {
        EntityManager em = getEntityManager();
        try {
            return em.find(Servicio.class, id);
        } finally {
            em.close();
        }
    }

    public int getServicioCount() {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            Root<Servicio> rt = cq.from(Servicio.class);
            cq.select(em.getCriteriaBuilder().count(rt));
            Query q = em.createQuery(cq);
            return ((Long) q.getSingleResult()).intValue();
        } finally {
            em.close();
        }
    }
    
}
