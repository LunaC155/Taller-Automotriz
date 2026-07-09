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
import com.upec.model.Repuesto;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.transaction.UserTransaction;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author ACER NITRO V15
 */
public class RepuestoJpaController implements Serializable {

    public RepuestoJpaController(UserTransaction utx, EntityManagerFactory emf) {
        this.utx = utx;
        this.emf = emf;
    }
    private UserTransaction utx = null;
    private EntityManagerFactory emf = null;

    public EntityManager getEntityManager() {
        return emf.createEntityManager();
    }

    public void create(Repuesto repuesto) throws RollbackFailureException, Exception {
        if (repuesto.getDetalleFacturaList() == null) {
            repuesto.setDetalleFacturaList(new ArrayList<DetalleFactura>());
        }
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            List<DetalleFactura> attachedDetalleFacturaList = new ArrayList<DetalleFactura>();
            for (DetalleFactura detalleFacturaListDetalleFacturaToAttach : repuesto.getDetalleFacturaList()) {
                detalleFacturaListDetalleFacturaToAttach = em.getReference(detalleFacturaListDetalleFacturaToAttach.getClass(), detalleFacturaListDetalleFacturaToAttach.getIDDetalleFactura());
                attachedDetalleFacturaList.add(detalleFacturaListDetalleFacturaToAttach);
            }
            repuesto.setDetalleFacturaList(attachedDetalleFacturaList);
            em.persist(repuesto);
            for (DetalleFactura detalleFacturaListDetalleFactura : repuesto.getDetalleFacturaList()) {
                Repuesto oldIDRepuestoOfDetalleFacturaListDetalleFactura = detalleFacturaListDetalleFactura.getIDRepuesto();
                detalleFacturaListDetalleFactura.setIDRepuesto(repuesto);
                detalleFacturaListDetalleFactura = em.merge(detalleFacturaListDetalleFactura);
                if (oldIDRepuestoOfDetalleFacturaListDetalleFactura != null) {
                    oldIDRepuestoOfDetalleFacturaListDetalleFactura.getDetalleFacturaList().remove(detalleFacturaListDetalleFactura);
                    oldIDRepuestoOfDetalleFacturaListDetalleFactura = em.merge(oldIDRepuestoOfDetalleFacturaListDetalleFactura);
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

    public void edit(Repuesto repuesto) throws NonexistentEntityException, RollbackFailureException, Exception {
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            Repuesto persistentRepuesto = em.find(Repuesto.class, repuesto.getIDRepuesto());
            List<DetalleFactura> detalleFacturaListOld = persistentRepuesto.getDetalleFacturaList();
            List<DetalleFactura> detalleFacturaListNew = repuesto.getDetalleFacturaList();
            List<DetalleFactura> attachedDetalleFacturaListNew = new ArrayList<DetalleFactura>();
            for (DetalleFactura detalleFacturaListNewDetalleFacturaToAttach : detalleFacturaListNew) {
                detalleFacturaListNewDetalleFacturaToAttach = em.getReference(detalleFacturaListNewDetalleFacturaToAttach.getClass(), detalleFacturaListNewDetalleFacturaToAttach.getIDDetalleFactura());
                attachedDetalleFacturaListNew.add(detalleFacturaListNewDetalleFacturaToAttach);
            }
            detalleFacturaListNew = attachedDetalleFacturaListNew;
            repuesto.setDetalleFacturaList(detalleFacturaListNew);
            repuesto = em.merge(repuesto);
            for (DetalleFactura detalleFacturaListOldDetalleFactura : detalleFacturaListOld) {
                if (!detalleFacturaListNew.contains(detalleFacturaListOldDetalleFactura)) {
                    detalleFacturaListOldDetalleFactura.setIDRepuesto(null);
                    detalleFacturaListOldDetalleFactura = em.merge(detalleFacturaListOldDetalleFactura);
                }
            }
            for (DetalleFactura detalleFacturaListNewDetalleFactura : detalleFacturaListNew) {
                if (!detalleFacturaListOld.contains(detalleFacturaListNewDetalleFactura)) {
                    Repuesto oldIDRepuestoOfDetalleFacturaListNewDetalleFactura = detalleFacturaListNewDetalleFactura.getIDRepuesto();
                    detalleFacturaListNewDetalleFactura.setIDRepuesto(repuesto);
                    detalleFacturaListNewDetalleFactura = em.merge(detalleFacturaListNewDetalleFactura);
                    if (oldIDRepuestoOfDetalleFacturaListNewDetalleFactura != null && !oldIDRepuestoOfDetalleFacturaListNewDetalleFactura.equals(repuesto)) {
                        oldIDRepuestoOfDetalleFacturaListNewDetalleFactura.getDetalleFacturaList().remove(detalleFacturaListNewDetalleFactura);
                        oldIDRepuestoOfDetalleFacturaListNewDetalleFactura = em.merge(oldIDRepuestoOfDetalleFacturaListNewDetalleFactura);
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
                Integer id = repuesto.getIDRepuesto();
                if (findRepuesto(id) == null) {
                    throw new NonexistentEntityException("The repuesto with id " + id + " no longer exists.");
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
            Repuesto repuesto;
            try {
                repuesto = em.getReference(Repuesto.class, id);
                repuesto.getIDRepuesto();
            } catch (EntityNotFoundException enfe) {
                throw new NonexistentEntityException("The repuesto with id " + id + " no longer exists.", enfe);
            }
            List<DetalleFactura> detalleFacturaList = repuesto.getDetalleFacturaList();
            for (DetalleFactura detalleFacturaListDetalleFactura : detalleFacturaList) {
                detalleFacturaListDetalleFactura.setIDRepuesto(null);
                detalleFacturaListDetalleFactura = em.merge(detalleFacturaListDetalleFactura);
            }
            em.remove(repuesto);
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

    public List<Repuesto> findRepuestoEntities() {
        return findRepuestoEntities(true, -1, -1);
    }

    public List<Repuesto> findRepuestoEntities(int maxResults, int firstResult) {
        return findRepuestoEntities(false, maxResults, firstResult);
    }

    private List<Repuesto> findRepuestoEntities(boolean all, int maxResults, int firstResult) {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            cq.select(cq.from(Repuesto.class));
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

    public Repuesto findRepuesto(Integer id) {
        EntityManager em = getEntityManager();
        try {
            return em.find(Repuesto.class, id);
        } finally {
            em.close();
        }
    }

    public int getRepuestoCount() {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            Root<Repuesto> rt = cq.from(Repuesto.class);
            cq.select(em.getCriteriaBuilder().count(rt));
            Query q = em.createQuery(cq);
            return ((Long) q.getSingleResult()).intValue();
        } finally {
            em.close();
        }
    }
    
}
