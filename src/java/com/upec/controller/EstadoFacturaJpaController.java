/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.upec.controller;

import com.upec.controller.exceptions.IllegalOrphanException;
import com.upec.controller.exceptions.NonexistentEntityException;
import com.upec.controller.exceptions.RollbackFailureException;
import com.upec.model.EstadoFactura;
import java.io.Serializable;
import jakarta.persistence.Query;
import jakarta.persistence.EntityNotFoundException;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Root;
import com.upec.model.Factura;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.transaction.UserTransaction;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author ACER NITRO V15
 */
public class EstadoFacturaJpaController implements Serializable {

    public EstadoFacturaJpaController(UserTransaction utx, EntityManagerFactory emf) {
        this.utx = utx;
        this.emf = emf;
    }
    private UserTransaction utx = null;
    private EntityManagerFactory emf = null;

    public EntityManager getEntityManager() {
        return emf.createEntityManager();
    }

    public void create(EstadoFactura estadoFactura) throws RollbackFailureException, Exception {
        if (estadoFactura.getFacturaList() == null) {
            estadoFactura.setFacturaList(new ArrayList<Factura>());
        }
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            List<Factura> attachedFacturaList = new ArrayList<Factura>();
            for (Factura facturaListFacturaToAttach : estadoFactura.getFacturaList()) {
                facturaListFacturaToAttach = em.getReference(facturaListFacturaToAttach.getClass(), facturaListFacturaToAttach.getIDFactura());
                attachedFacturaList.add(facturaListFacturaToAttach);
            }
            estadoFactura.setFacturaList(attachedFacturaList);
            em.persist(estadoFactura);
            for (Factura facturaListFactura : estadoFactura.getFacturaList()) {
                EstadoFactura oldIDEstadoFacturaOfFacturaListFactura = facturaListFactura.getIDEstadoFactura();
                facturaListFactura.setIDEstadoFactura(estadoFactura);
                facturaListFactura = em.merge(facturaListFactura);
                if (oldIDEstadoFacturaOfFacturaListFactura != null) {
                    oldIDEstadoFacturaOfFacturaListFactura.getFacturaList().remove(facturaListFactura);
                    oldIDEstadoFacturaOfFacturaListFactura = em.merge(oldIDEstadoFacturaOfFacturaListFactura);
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

    public void edit(EstadoFactura estadoFactura) throws IllegalOrphanException, NonexistentEntityException, RollbackFailureException, Exception {
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            EstadoFactura persistentEstadoFactura = em.find(EstadoFactura.class, estadoFactura.getIDEstadoFactura());
            List<Factura> facturaListOld = persistentEstadoFactura.getFacturaList();
            List<Factura> facturaListNew = estadoFactura.getFacturaList();
            List<String> illegalOrphanMessages = null;
            for (Factura facturaListOldFactura : facturaListOld) {
                if (!facturaListNew.contains(facturaListOldFactura)) {
                    if (illegalOrphanMessages == null) {
                        illegalOrphanMessages = new ArrayList<String>();
                    }
                    illegalOrphanMessages.add("You must retain Factura " + facturaListOldFactura + " since its IDEstadoFactura field is not nullable.");
                }
            }
            if (illegalOrphanMessages != null) {
                throw new IllegalOrphanException(illegalOrphanMessages);
            }
            List<Factura> attachedFacturaListNew = new ArrayList<Factura>();
            for (Factura facturaListNewFacturaToAttach : facturaListNew) {
                facturaListNewFacturaToAttach = em.getReference(facturaListNewFacturaToAttach.getClass(), facturaListNewFacturaToAttach.getIDFactura());
                attachedFacturaListNew.add(facturaListNewFacturaToAttach);
            }
            facturaListNew = attachedFacturaListNew;
            estadoFactura.setFacturaList(facturaListNew);
            estadoFactura = em.merge(estadoFactura);
            for (Factura facturaListNewFactura : facturaListNew) {
                if (!facturaListOld.contains(facturaListNewFactura)) {
                    EstadoFactura oldIDEstadoFacturaOfFacturaListNewFactura = facturaListNewFactura.getIDEstadoFactura();
                    facturaListNewFactura.setIDEstadoFactura(estadoFactura);
                    facturaListNewFactura = em.merge(facturaListNewFactura);
                    if (oldIDEstadoFacturaOfFacturaListNewFactura != null && !oldIDEstadoFacturaOfFacturaListNewFactura.equals(estadoFactura)) {
                        oldIDEstadoFacturaOfFacturaListNewFactura.getFacturaList().remove(facturaListNewFactura);
                        oldIDEstadoFacturaOfFacturaListNewFactura = em.merge(oldIDEstadoFacturaOfFacturaListNewFactura);
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
                Integer id = estadoFactura.getIDEstadoFactura();
                if (findEstadoFactura(id) == null) {
                    throw new NonexistentEntityException("The estadoFactura with id " + id + " no longer exists.");
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
            EstadoFactura estadoFactura;
            try {
                estadoFactura = em.getReference(EstadoFactura.class, id);
                estadoFactura.getIDEstadoFactura();
            } catch (EntityNotFoundException enfe) {
                throw new NonexistentEntityException("The estadoFactura with id " + id + " no longer exists.", enfe);
            }
            List<String> illegalOrphanMessages = null;
            List<Factura> facturaListOrphanCheck = estadoFactura.getFacturaList();
            for (Factura facturaListOrphanCheckFactura : facturaListOrphanCheck) {
                if (illegalOrphanMessages == null) {
                    illegalOrphanMessages = new ArrayList<String>();
                }
                illegalOrphanMessages.add("This EstadoFactura (" + estadoFactura + ") cannot be destroyed since the Factura " + facturaListOrphanCheckFactura + " in its facturaList field has a non-nullable IDEstadoFactura field.");
            }
            if (illegalOrphanMessages != null) {
                throw new IllegalOrphanException(illegalOrphanMessages);
            }
            em.remove(estadoFactura);
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

    public List<EstadoFactura> findEstadoFacturaEntities() {
        return findEstadoFacturaEntities(true, -1, -1);
    }

    public List<EstadoFactura> findEstadoFacturaEntities(int maxResults, int firstResult) {
        return findEstadoFacturaEntities(false, maxResults, firstResult);
    }

    private List<EstadoFactura> findEstadoFacturaEntities(boolean all, int maxResults, int firstResult) {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            cq.select(cq.from(EstadoFactura.class));
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

    public EstadoFactura findEstadoFactura(Integer id) {
        EntityManager em = getEntityManager();
        try {
            return em.find(EstadoFactura.class, id);
        } finally {
            em.close();
        }
    }

    public int getEstadoFacturaCount() {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            Root<EstadoFactura> rt = cq.from(EstadoFactura.class);
            cq.select(em.getCriteriaBuilder().count(rt));
            Query q = em.createQuery(cq);
            return ((Long) q.getSingleResult()).intValue();
        } finally {
            em.close();
        }
    }
    
}
