/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.upec.controller;

import com.upec.controller.exceptions.IllegalOrphanException;
import com.upec.controller.exceptions.NonexistentEntityException;
import com.upec.controller.exceptions.RollbackFailureException;
import com.upec.model.FormaPago;
import java.io.Serializable;
import jakarta.persistence.Query;
import jakarta.persistence.EntityNotFoundException;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Root;
import com.upec.model.Pago;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.transaction.UserTransaction;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author ACER NITRO V15
 */
public class FormaPagoJpaController implements Serializable {

    public FormaPagoJpaController(UserTransaction utx, EntityManagerFactory emf) {
        this.utx = utx;
        this.emf = emf;
    }
    private UserTransaction utx = null;
    private EntityManagerFactory emf = null;

    public EntityManager getEntityManager() {
        return emf.createEntityManager();
    }

    public void create(FormaPago formaPago) throws RollbackFailureException, Exception {
        if (formaPago.getPagoList() == null) {
            formaPago.setPagoList(new ArrayList<Pago>());
        }
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            List<Pago> attachedPagoList = new ArrayList<Pago>();
            for (Pago pagoListPagoToAttach : formaPago.getPagoList()) {
                pagoListPagoToAttach = em.getReference(pagoListPagoToAttach.getClass(), pagoListPagoToAttach.getIDPago());
                attachedPagoList.add(pagoListPagoToAttach);
            }
            formaPago.setPagoList(attachedPagoList);
            em.persist(formaPago);
            for (Pago pagoListPago : formaPago.getPagoList()) {
                FormaPago oldIDFormaPagoOfPagoListPago = pagoListPago.getIDFormaPago();
                pagoListPago.setIDFormaPago(formaPago);
                pagoListPago = em.merge(pagoListPago);
                if (oldIDFormaPagoOfPagoListPago != null) {
                    oldIDFormaPagoOfPagoListPago.getPagoList().remove(pagoListPago);
                    oldIDFormaPagoOfPagoListPago = em.merge(oldIDFormaPagoOfPagoListPago);
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

    public void edit(FormaPago formaPago) throws IllegalOrphanException, NonexistentEntityException, RollbackFailureException, Exception {
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            FormaPago persistentFormaPago = em.find(FormaPago.class, formaPago.getIDFormaPago());
            List<Pago> pagoListOld = persistentFormaPago.getPagoList();
            List<Pago> pagoListNew = formaPago.getPagoList();
            List<String> illegalOrphanMessages = null;
            for (Pago pagoListOldPago : pagoListOld) {
                if (!pagoListNew.contains(pagoListOldPago)) {
                    if (illegalOrphanMessages == null) {
                        illegalOrphanMessages = new ArrayList<String>();
                    }
                    illegalOrphanMessages.add("You must retain Pago " + pagoListOldPago + " since its IDFormaPago field is not nullable.");
                }
            }
            if (illegalOrphanMessages != null) {
                throw new IllegalOrphanException(illegalOrphanMessages);
            }
            List<Pago> attachedPagoListNew = new ArrayList<Pago>();
            for (Pago pagoListNewPagoToAttach : pagoListNew) {
                pagoListNewPagoToAttach = em.getReference(pagoListNewPagoToAttach.getClass(), pagoListNewPagoToAttach.getIDPago());
                attachedPagoListNew.add(pagoListNewPagoToAttach);
            }
            pagoListNew = attachedPagoListNew;
            formaPago.setPagoList(pagoListNew);
            formaPago = em.merge(formaPago);
            for (Pago pagoListNewPago : pagoListNew) {
                if (!pagoListOld.contains(pagoListNewPago)) {
                    FormaPago oldIDFormaPagoOfPagoListNewPago = pagoListNewPago.getIDFormaPago();
                    pagoListNewPago.setIDFormaPago(formaPago);
                    pagoListNewPago = em.merge(pagoListNewPago);
                    if (oldIDFormaPagoOfPagoListNewPago != null && !oldIDFormaPagoOfPagoListNewPago.equals(formaPago)) {
                        oldIDFormaPagoOfPagoListNewPago.getPagoList().remove(pagoListNewPago);
                        oldIDFormaPagoOfPagoListNewPago = em.merge(oldIDFormaPagoOfPagoListNewPago);
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
                Integer id = formaPago.getIDFormaPago();
                if (findFormaPago(id) == null) {
                    throw new NonexistentEntityException("The formaPago with id " + id + " no longer exists.");
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
            FormaPago formaPago;
            try {
                formaPago = em.getReference(FormaPago.class, id);
                formaPago.getIDFormaPago();
            } catch (EntityNotFoundException enfe) {
                throw new NonexistentEntityException("The formaPago with id " + id + " no longer exists.", enfe);
            }
            List<String> illegalOrphanMessages = null;
            List<Pago> pagoListOrphanCheck = formaPago.getPagoList();
            for (Pago pagoListOrphanCheckPago : pagoListOrphanCheck) {
                if (illegalOrphanMessages == null) {
                    illegalOrphanMessages = new ArrayList<String>();
                }
                illegalOrphanMessages.add("This FormaPago (" + formaPago + ") cannot be destroyed since the Pago " + pagoListOrphanCheckPago + " in its pagoList field has a non-nullable IDFormaPago field.");
            }
            if (illegalOrphanMessages != null) {
                throw new IllegalOrphanException(illegalOrphanMessages);
            }
            em.remove(formaPago);
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

    public List<FormaPago> findFormaPagoEntities() {
        return findFormaPagoEntities(true, -1, -1);
    }

    public List<FormaPago> findFormaPagoEntities(int maxResults, int firstResult) {
        return findFormaPagoEntities(false, maxResults, firstResult);
    }

    private List<FormaPago> findFormaPagoEntities(boolean all, int maxResults, int firstResult) {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            cq.select(cq.from(FormaPago.class));
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

    public FormaPago findFormaPago(Integer id) {
        EntityManager em = getEntityManager();
        try {
            return em.find(FormaPago.class, id);
        } finally {
            em.close();
        }
    }

    public int getFormaPagoCount() {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            Root<FormaPago> rt = cq.from(FormaPago.class);
            cq.select(em.getCriteriaBuilder().count(rt));
            Query q = em.createQuery(cq);
            return ((Long) q.getSingleResult()).intValue();
        } finally {
            em.close();
        }
    }
    
}
