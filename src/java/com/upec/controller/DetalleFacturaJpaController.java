/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.upec.controller;

import com.upec.controller.exceptions.NonexistentEntityException;
import com.upec.controller.exceptions.RollbackFailureException;
import com.upec.model.DetalleFactura;
import java.io.Serializable;
import jakarta.persistence.Query;
import jakarta.persistence.EntityNotFoundException;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Root;
import com.upec.model.Factura;
import com.upec.model.Repuesto;
import com.upec.model.Servicio;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.transaction.UserTransaction;
import java.util.List;

/**
 *
 * @author ACER NITRO V15
 */
public class DetalleFacturaJpaController implements Serializable {

    public DetalleFacturaJpaController(UserTransaction utx, EntityManagerFactory emf) {
        this.utx = utx;
        this.emf = emf;
    }
    private UserTransaction utx = null;
    private EntityManagerFactory emf = null;

    public EntityManager getEntityManager() {
        return emf.createEntityManager();
    }

    public void create(DetalleFactura detalleFactura) throws RollbackFailureException, Exception {
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            Factura IDFactura = detalleFactura.getIDFactura();
            if (IDFactura != null) {
                IDFactura = em.getReference(IDFactura.getClass(), IDFactura.getIDFactura());
                detalleFactura.setIDFactura(IDFactura);
            }
            Repuesto IDRepuesto = detalleFactura.getIDRepuesto();
            if (IDRepuesto != null) {
                IDRepuesto = em.getReference(IDRepuesto.getClass(), IDRepuesto.getIDRepuesto());
                detalleFactura.setIDRepuesto(IDRepuesto);
            }
            Servicio IDServicio = detalleFactura.getIDServicio();
            if (IDServicio != null) {
                IDServicio = em.getReference(IDServicio.getClass(), IDServicio.getIDServicio());
                detalleFactura.setIDServicio(IDServicio);
            }
            em.persist(detalleFactura);
            if (IDFactura != null) {
                IDFactura.getDetalleFacturaList().add(detalleFactura);
                IDFactura = em.merge(IDFactura);
            }
            if (IDRepuesto != null) {
                IDRepuesto.getDetalleFacturaList().add(detalleFactura);
                IDRepuesto = em.merge(IDRepuesto);
            }
            if (IDServicio != null) {
                IDServicio.getDetalleFacturaList().add(detalleFactura);
                IDServicio = em.merge(IDServicio);
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

    public void edit(DetalleFactura detalleFactura) throws NonexistentEntityException, RollbackFailureException, Exception {
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            DetalleFactura persistentDetalleFactura = em.find(DetalleFactura.class, detalleFactura.getIDDetalleFactura());
            Factura IDFacturaOld = persistentDetalleFactura.getIDFactura();
            Factura IDFacturaNew = detalleFactura.getIDFactura();
            Repuesto IDRepuestoOld = persistentDetalleFactura.getIDRepuesto();
            Repuesto IDRepuestoNew = detalleFactura.getIDRepuesto();
            Servicio IDServicioOld = persistentDetalleFactura.getIDServicio();
            Servicio IDServicioNew = detalleFactura.getIDServicio();
            if (IDFacturaNew != null) {
                IDFacturaNew = em.getReference(IDFacturaNew.getClass(), IDFacturaNew.getIDFactura());
                detalleFactura.setIDFactura(IDFacturaNew);
            }
            if (IDRepuestoNew != null) {
                IDRepuestoNew = em.getReference(IDRepuestoNew.getClass(), IDRepuestoNew.getIDRepuesto());
                detalleFactura.setIDRepuesto(IDRepuestoNew);
            }
            if (IDServicioNew != null) {
                IDServicioNew = em.getReference(IDServicioNew.getClass(), IDServicioNew.getIDServicio());
                detalleFactura.setIDServicio(IDServicioNew);
            }
            detalleFactura = em.merge(detalleFactura);
            if (IDFacturaOld != null && !IDFacturaOld.equals(IDFacturaNew)) {
                IDFacturaOld.getDetalleFacturaList().remove(detalleFactura);
                IDFacturaOld = em.merge(IDFacturaOld);
            }
            if (IDFacturaNew != null && !IDFacturaNew.equals(IDFacturaOld)) {
                IDFacturaNew.getDetalleFacturaList().add(detalleFactura);
                IDFacturaNew = em.merge(IDFacturaNew);
            }
            if (IDRepuestoOld != null && !IDRepuestoOld.equals(IDRepuestoNew)) {
                IDRepuestoOld.getDetalleFacturaList().remove(detalleFactura);
                IDRepuestoOld = em.merge(IDRepuestoOld);
            }
            if (IDRepuestoNew != null && !IDRepuestoNew.equals(IDRepuestoOld)) {
                IDRepuestoNew.getDetalleFacturaList().add(detalleFactura);
                IDRepuestoNew = em.merge(IDRepuestoNew);
            }
            if (IDServicioOld != null && !IDServicioOld.equals(IDServicioNew)) {
                IDServicioOld.getDetalleFacturaList().remove(detalleFactura);
                IDServicioOld = em.merge(IDServicioOld);
            }
            if (IDServicioNew != null && !IDServicioNew.equals(IDServicioOld)) {
                IDServicioNew.getDetalleFacturaList().add(detalleFactura);
                IDServicioNew = em.merge(IDServicioNew);
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
                Integer id = detalleFactura.getIDDetalleFactura();
                if (findDetalleFactura(id) == null) {
                    throw new NonexistentEntityException("The detalleFactura with id " + id + " no longer exists.");
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
            DetalleFactura detalleFactura;
            try {
                detalleFactura = em.getReference(DetalleFactura.class, id);
                detalleFactura.getIDDetalleFactura();
            } catch (EntityNotFoundException enfe) {
                throw new NonexistentEntityException("The detalleFactura with id " + id + " no longer exists.", enfe);
            }
            Factura IDFactura = detalleFactura.getIDFactura();
            if (IDFactura != null) {
                IDFactura.getDetalleFacturaList().remove(detalleFactura);
                IDFactura = em.merge(IDFactura);
            }
            Repuesto IDRepuesto = detalleFactura.getIDRepuesto();
            if (IDRepuesto != null) {
                IDRepuesto.getDetalleFacturaList().remove(detalleFactura);
                IDRepuesto = em.merge(IDRepuesto);
            }
            Servicio IDServicio = detalleFactura.getIDServicio();
            if (IDServicio != null) {
                IDServicio.getDetalleFacturaList().remove(detalleFactura);
                IDServicio = em.merge(IDServicio);
            }
            em.remove(detalleFactura);
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

    public List<DetalleFactura> findDetalleFacturaEntities() {
        return findDetalleFacturaEntities(true, -1, -1);
    }

    public List<DetalleFactura> findDetalleFacturaEntities(int maxResults, int firstResult) {
        return findDetalleFacturaEntities(false, maxResults, firstResult);
    }

    private List<DetalleFactura> findDetalleFacturaEntities(boolean all, int maxResults, int firstResult) {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            cq.select(cq.from(DetalleFactura.class));
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

    public DetalleFactura findDetalleFactura(Integer id) {
        EntityManager em = getEntityManager();
        try {
            return em.find(DetalleFactura.class, id);
        } finally {
            em.close();
        }
    }

    public int getDetalleFacturaCount() {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            Root<DetalleFactura> rt = cq.from(DetalleFactura.class);
            cq.select(em.getCriteriaBuilder().count(rt));
            Query q = em.createQuery(cq);
            return ((Long) q.getSingleResult()).intValue();
        } finally {
            em.close();
        }
    }
    
}
