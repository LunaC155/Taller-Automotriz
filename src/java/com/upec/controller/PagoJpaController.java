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
import com.upec.model.Factura;
import com.upec.model.FormaPago;
import com.upec.model.Pago;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.transaction.UserTransaction;
import java.util.List;

/**
 *
 * @author ACER NITRO V15
 */
public class PagoJpaController implements Serializable {

    public PagoJpaController(UserTransaction utx, EntityManagerFactory emf) {
        this.utx = utx;
        this.emf = emf;
    }
    private UserTransaction utx = null;
    private EntityManagerFactory emf = null;

    public EntityManager getEntityManager() {
        return emf.createEntityManager();
    }

    public void create(Pago pago) throws RollbackFailureException, Exception {
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            Factura IDFactura = pago.getIDFactura();
            if (IDFactura != null) {
                IDFactura = em.getReference(IDFactura.getClass(), IDFactura.getIDFactura());
                pago.setIDFactura(IDFactura);
            }
            FormaPago IDFormaPago = pago.getIDFormaPago();
            if (IDFormaPago != null) {
                IDFormaPago = em.getReference(IDFormaPago.getClass(), IDFormaPago.getIDFormaPago());
                pago.setIDFormaPago(IDFormaPago);
            }
            em.persist(pago);
            if (IDFactura != null) {
                IDFactura.getPagoList().add(pago);
                IDFactura = em.merge(IDFactura);
            }
            if (IDFormaPago != null) {
                IDFormaPago.getPagoList().add(pago);
                IDFormaPago = em.merge(IDFormaPago);
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

    public void edit(Pago pago) throws NonexistentEntityException, RollbackFailureException, Exception {
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            Pago persistentPago = em.find(Pago.class, pago.getIDPago());
            Factura IDFacturaOld = persistentPago.getIDFactura();
            Factura IDFacturaNew = pago.getIDFactura();
            FormaPago IDFormaPagoOld = persistentPago.getIDFormaPago();
            FormaPago IDFormaPagoNew = pago.getIDFormaPago();
            if (IDFacturaNew != null) {
                IDFacturaNew = em.getReference(IDFacturaNew.getClass(), IDFacturaNew.getIDFactura());
                pago.setIDFactura(IDFacturaNew);
            }
            if (IDFormaPagoNew != null) {
                IDFormaPagoNew = em.getReference(IDFormaPagoNew.getClass(), IDFormaPagoNew.getIDFormaPago());
                pago.setIDFormaPago(IDFormaPagoNew);
            }
            pago = em.merge(pago);
            if (IDFacturaOld != null && !IDFacturaOld.equals(IDFacturaNew)) {
                IDFacturaOld.getPagoList().remove(pago);
                IDFacturaOld = em.merge(IDFacturaOld);
            }
            if (IDFacturaNew != null && !IDFacturaNew.equals(IDFacturaOld)) {
                IDFacturaNew.getPagoList().add(pago);
                IDFacturaNew = em.merge(IDFacturaNew);
            }
            if (IDFormaPagoOld != null && !IDFormaPagoOld.equals(IDFormaPagoNew)) {
                IDFormaPagoOld.getPagoList().remove(pago);
                IDFormaPagoOld = em.merge(IDFormaPagoOld);
            }
            if (IDFormaPagoNew != null && !IDFormaPagoNew.equals(IDFormaPagoOld)) {
                IDFormaPagoNew.getPagoList().add(pago);
                IDFormaPagoNew = em.merge(IDFormaPagoNew);
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
                Integer id = pago.getIDPago();
                if (findPago(id) == null) {
                    throw new NonexistentEntityException("The pago with id " + id + " no longer exists.");
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
            Pago pago;
            try {
                pago = em.getReference(Pago.class, id);
                pago.getIDPago();
            } catch (EntityNotFoundException enfe) {
                throw new NonexistentEntityException("The pago with id " + id + " no longer exists.", enfe);
            }
            Factura IDFactura = pago.getIDFactura();
            if (IDFactura != null) {
                IDFactura.getPagoList().remove(pago);
                IDFactura = em.merge(IDFactura);
            }
            FormaPago IDFormaPago = pago.getIDFormaPago();
            if (IDFormaPago != null) {
                IDFormaPago.getPagoList().remove(pago);
                IDFormaPago = em.merge(IDFormaPago);
            }
            em.remove(pago);
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

    public List<Pago> findPagoEntities() {
        return findPagoEntities(true, -1, -1);
    }

    public List<Pago> findPagoEntities(int maxResults, int firstResult) {
        return findPagoEntities(false, maxResults, firstResult);
    }

    private List<Pago> findPagoEntities(boolean all, int maxResults, int firstResult) {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            cq.select(cq.from(Pago.class));
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

    public Pago findPago(Integer id) {
        EntityManager em = getEntityManager();
        try {
            return em.find(Pago.class, id);
        } finally {
            em.close();
        }
    }

    public int getPagoCount() {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            Root<Pago> rt = cq.from(Pago.class);
            cq.select(em.getCriteriaBuilder().count(rt));
            Query q = em.createQuery(cq);
            return ((Long) q.getSingleResult()).intValue();
        } finally {
            em.close();
        }
    }
    
}
