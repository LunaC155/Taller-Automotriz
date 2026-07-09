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
import com.upec.model.EstadoFactura;
import com.upec.model.OrdenServicio;
import com.upec.model.DetalleFactura;
import com.upec.model.Factura;
import java.util.ArrayList;
import java.util.List;
import com.upec.model.Pago;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.transaction.UserTransaction;

/**
 *
 * @author ACER NITRO V15
 */
public class FacturaJpaController implements Serializable {

    public FacturaJpaController(UserTransaction utx, EntityManagerFactory emf) {
        this.utx = utx;
        this.emf = emf;
    }
    private UserTransaction utx = null;
    private EntityManagerFactory emf = null;

    public EntityManager getEntityManager() {
        return emf.createEntityManager();
    }

    public void create(Factura factura) throws RollbackFailureException, Exception {
        if (factura.getDetalleFacturaList() == null) {
            factura.setDetalleFacturaList(new ArrayList<DetalleFactura>());
        }
        if (factura.getPagoList() == null) {
            factura.setPagoList(new ArrayList<Pago>());
        }
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            EstadoFactura IDEstadoFactura = factura.getIDEstadoFactura();
            if (IDEstadoFactura != null) {
                IDEstadoFactura = em.getReference(IDEstadoFactura.getClass(), IDEstadoFactura.getIDEstadoFactura());
                factura.setIDEstadoFactura(IDEstadoFactura);
            }
            OrdenServicio IDOrdenServicio = factura.getIDOrdenServicio();
            if (IDOrdenServicio != null) {
                IDOrdenServicio = em.getReference(IDOrdenServicio.getClass(), IDOrdenServicio.getIDOrdenServicio());
                factura.setIDOrdenServicio(IDOrdenServicio);
            }
            List<DetalleFactura> attachedDetalleFacturaList = new ArrayList<DetalleFactura>();
            for (DetalleFactura detalleFacturaListDetalleFacturaToAttach : factura.getDetalleFacturaList()) {
                detalleFacturaListDetalleFacturaToAttach = em.getReference(detalleFacturaListDetalleFacturaToAttach.getClass(), detalleFacturaListDetalleFacturaToAttach.getIDDetalleFactura());
                attachedDetalleFacturaList.add(detalleFacturaListDetalleFacturaToAttach);
            }
            factura.setDetalleFacturaList(attachedDetalleFacturaList);
            List<Pago> attachedPagoList = new ArrayList<Pago>();
            for (Pago pagoListPagoToAttach : factura.getPagoList()) {
                pagoListPagoToAttach = em.getReference(pagoListPagoToAttach.getClass(), pagoListPagoToAttach.getIDPago());
                attachedPagoList.add(pagoListPagoToAttach);
            }
            factura.setPagoList(attachedPagoList);
            em.persist(factura);
            if (IDEstadoFactura != null) {
                IDEstadoFactura.getFacturaList().add(factura);
                IDEstadoFactura = em.merge(IDEstadoFactura);
            }
            if (IDOrdenServicio != null) {
                IDOrdenServicio.getFacturaList().add(factura);
                IDOrdenServicio = em.merge(IDOrdenServicio);
            }
            for (DetalleFactura detalleFacturaListDetalleFactura : factura.getDetalleFacturaList()) {
                Factura oldIDFacturaOfDetalleFacturaListDetalleFactura = detalleFacturaListDetalleFactura.getIDFactura();
                detalleFacturaListDetalleFactura.setIDFactura(factura);
                detalleFacturaListDetalleFactura = em.merge(detalleFacturaListDetalleFactura);
                if (oldIDFacturaOfDetalleFacturaListDetalleFactura != null) {
                    oldIDFacturaOfDetalleFacturaListDetalleFactura.getDetalleFacturaList().remove(detalleFacturaListDetalleFactura);
                    oldIDFacturaOfDetalleFacturaListDetalleFactura = em.merge(oldIDFacturaOfDetalleFacturaListDetalleFactura);
                }
            }
            for (Pago pagoListPago : factura.getPagoList()) {
                Factura oldIDFacturaOfPagoListPago = pagoListPago.getIDFactura();
                pagoListPago.setIDFactura(factura);
                pagoListPago = em.merge(pagoListPago);
                if (oldIDFacturaOfPagoListPago != null) {
                    oldIDFacturaOfPagoListPago.getPagoList().remove(pagoListPago);
                    oldIDFacturaOfPagoListPago = em.merge(oldIDFacturaOfPagoListPago);
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

    public void edit(Factura factura) throws IllegalOrphanException, NonexistentEntityException, RollbackFailureException, Exception {
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            Factura persistentFactura = em.find(Factura.class, factura.getIDFactura());
            EstadoFactura IDEstadoFacturaOld = persistentFactura.getIDEstadoFactura();
            EstadoFactura IDEstadoFacturaNew = factura.getIDEstadoFactura();
            OrdenServicio IDOrdenServicioOld = persistentFactura.getIDOrdenServicio();
            OrdenServicio IDOrdenServicioNew = factura.getIDOrdenServicio();
            List<DetalleFactura> detalleFacturaListOld = persistentFactura.getDetalleFacturaList();
            List<DetalleFactura> detalleFacturaListNew = factura.getDetalleFacturaList();
            List<Pago> pagoListOld = persistentFactura.getPagoList();
            List<Pago> pagoListNew = factura.getPagoList();
            List<String> illegalOrphanMessages = null;
            for (DetalleFactura detalleFacturaListOldDetalleFactura : detalleFacturaListOld) {
                if (!detalleFacturaListNew.contains(detalleFacturaListOldDetalleFactura)) {
                    if (illegalOrphanMessages == null) {
                        illegalOrphanMessages = new ArrayList<String>();
                    }
                    illegalOrphanMessages.add("You must retain DetalleFactura " + detalleFacturaListOldDetalleFactura + " since its IDFactura field is not nullable.");
                }
            }
            for (Pago pagoListOldPago : pagoListOld) {
                if (!pagoListNew.contains(pagoListOldPago)) {
                    if (illegalOrphanMessages == null) {
                        illegalOrphanMessages = new ArrayList<String>();
                    }
                    illegalOrphanMessages.add("You must retain Pago " + pagoListOldPago + " since its IDFactura field is not nullable.");
                }
            }
            if (illegalOrphanMessages != null) {
                throw new IllegalOrphanException(illegalOrphanMessages);
            }
            if (IDEstadoFacturaNew != null) {
                IDEstadoFacturaNew = em.getReference(IDEstadoFacturaNew.getClass(), IDEstadoFacturaNew.getIDEstadoFactura());
                factura.setIDEstadoFactura(IDEstadoFacturaNew);
            }
            if (IDOrdenServicioNew != null) {
                IDOrdenServicioNew = em.getReference(IDOrdenServicioNew.getClass(), IDOrdenServicioNew.getIDOrdenServicio());
                factura.setIDOrdenServicio(IDOrdenServicioNew);
            }
            List<DetalleFactura> attachedDetalleFacturaListNew = new ArrayList<DetalleFactura>();
            for (DetalleFactura detalleFacturaListNewDetalleFacturaToAttach : detalleFacturaListNew) {
                detalleFacturaListNewDetalleFacturaToAttach = em.getReference(detalleFacturaListNewDetalleFacturaToAttach.getClass(), detalleFacturaListNewDetalleFacturaToAttach.getIDDetalleFactura());
                attachedDetalleFacturaListNew.add(detalleFacturaListNewDetalleFacturaToAttach);
            }
            detalleFacturaListNew = attachedDetalleFacturaListNew;
            factura.setDetalleFacturaList(detalleFacturaListNew);
            List<Pago> attachedPagoListNew = new ArrayList<Pago>();
            for (Pago pagoListNewPagoToAttach : pagoListNew) {
                pagoListNewPagoToAttach = em.getReference(pagoListNewPagoToAttach.getClass(), pagoListNewPagoToAttach.getIDPago());
                attachedPagoListNew.add(pagoListNewPagoToAttach);
            }
            pagoListNew = attachedPagoListNew;
            factura.setPagoList(pagoListNew);
            factura = em.merge(factura);
            if (IDEstadoFacturaOld != null && !IDEstadoFacturaOld.equals(IDEstadoFacturaNew)) {
                IDEstadoFacturaOld.getFacturaList().remove(factura);
                IDEstadoFacturaOld = em.merge(IDEstadoFacturaOld);
            }
            if (IDEstadoFacturaNew != null && !IDEstadoFacturaNew.equals(IDEstadoFacturaOld)) {
                IDEstadoFacturaNew.getFacturaList().add(factura);
                IDEstadoFacturaNew = em.merge(IDEstadoFacturaNew);
            }
            if (IDOrdenServicioOld != null && !IDOrdenServicioOld.equals(IDOrdenServicioNew)) {
                IDOrdenServicioOld.getFacturaList().remove(factura);
                IDOrdenServicioOld = em.merge(IDOrdenServicioOld);
            }
            if (IDOrdenServicioNew != null && !IDOrdenServicioNew.equals(IDOrdenServicioOld)) {
                IDOrdenServicioNew.getFacturaList().add(factura);
                IDOrdenServicioNew = em.merge(IDOrdenServicioNew);
            }
            for (DetalleFactura detalleFacturaListNewDetalleFactura : detalleFacturaListNew) {
                if (!detalleFacturaListOld.contains(detalleFacturaListNewDetalleFactura)) {
                    Factura oldIDFacturaOfDetalleFacturaListNewDetalleFactura = detalleFacturaListNewDetalleFactura.getIDFactura();
                    detalleFacturaListNewDetalleFactura.setIDFactura(factura);
                    detalleFacturaListNewDetalleFactura = em.merge(detalleFacturaListNewDetalleFactura);
                    if (oldIDFacturaOfDetalleFacturaListNewDetalleFactura != null && !oldIDFacturaOfDetalleFacturaListNewDetalleFactura.equals(factura)) {
                        oldIDFacturaOfDetalleFacturaListNewDetalleFactura.getDetalleFacturaList().remove(detalleFacturaListNewDetalleFactura);
                        oldIDFacturaOfDetalleFacturaListNewDetalleFactura = em.merge(oldIDFacturaOfDetalleFacturaListNewDetalleFactura);
                    }
                }
            }
            for (Pago pagoListNewPago : pagoListNew) {
                if (!pagoListOld.contains(pagoListNewPago)) {
                    Factura oldIDFacturaOfPagoListNewPago = pagoListNewPago.getIDFactura();
                    pagoListNewPago.setIDFactura(factura);
                    pagoListNewPago = em.merge(pagoListNewPago);
                    if (oldIDFacturaOfPagoListNewPago != null && !oldIDFacturaOfPagoListNewPago.equals(factura)) {
                        oldIDFacturaOfPagoListNewPago.getPagoList().remove(pagoListNewPago);
                        oldIDFacturaOfPagoListNewPago = em.merge(oldIDFacturaOfPagoListNewPago);
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
                Integer id = factura.getIDFactura();
                if (findFactura(id) == null) {
                    throw new NonexistentEntityException("The factura with id " + id + " no longer exists.");
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
            Factura factura;
            try {
                factura = em.getReference(Factura.class, id);
                factura.getIDFactura();
            } catch (EntityNotFoundException enfe) {
                throw new NonexistentEntityException("The factura with id " + id + " no longer exists.", enfe);
            }
            List<String> illegalOrphanMessages = null;
            List<DetalleFactura> detalleFacturaListOrphanCheck = factura.getDetalleFacturaList();
            for (DetalleFactura detalleFacturaListOrphanCheckDetalleFactura : detalleFacturaListOrphanCheck) {
                if (illegalOrphanMessages == null) {
                    illegalOrphanMessages = new ArrayList<String>();
                }
                illegalOrphanMessages.add("This Factura (" + factura + ") cannot be destroyed since the DetalleFactura " + detalleFacturaListOrphanCheckDetalleFactura + " in its detalleFacturaList field has a non-nullable IDFactura field.");
            }
            List<Pago> pagoListOrphanCheck = factura.getPagoList();
            for (Pago pagoListOrphanCheckPago : pagoListOrphanCheck) {
                if (illegalOrphanMessages == null) {
                    illegalOrphanMessages = new ArrayList<String>();
                }
                illegalOrphanMessages.add("This Factura (" + factura + ") cannot be destroyed since the Pago " + pagoListOrphanCheckPago + " in its pagoList field has a non-nullable IDFactura field.");
            }
            if (illegalOrphanMessages != null) {
                throw new IllegalOrphanException(illegalOrphanMessages);
            }
            EstadoFactura IDEstadoFactura = factura.getIDEstadoFactura();
            if (IDEstadoFactura != null) {
                IDEstadoFactura.getFacturaList().remove(factura);
                IDEstadoFactura = em.merge(IDEstadoFactura);
            }
            OrdenServicio IDOrdenServicio = factura.getIDOrdenServicio();
            if (IDOrdenServicio != null) {
                IDOrdenServicio.getFacturaList().remove(factura);
                IDOrdenServicio = em.merge(IDOrdenServicio);
            }
            em.remove(factura);
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

    public List<Factura> findFacturaEntities() {
        return findFacturaEntities(true, -1, -1);
    }

    public List<Factura> findFacturaEntities(int maxResults, int firstResult) {
        return findFacturaEntities(false, maxResults, firstResult);
    }

    private List<Factura> findFacturaEntities(boolean all, int maxResults, int firstResult) {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            cq.select(cq.from(Factura.class));
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

    public Factura findFactura(Integer id) {
        EntityManager em = getEntityManager();
        try {
            return em.find(Factura.class, id);
        } finally {
            em.close();
        }
    }

    public int getFacturaCount() {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            Root<Factura> rt = cq.from(Factura.class);
            cq.select(em.getCriteriaBuilder().count(rt));
            Query q = em.createQuery(cq);
            return ((Long) q.getSingleResult()).intValue();
        } finally {
            em.close();
        }
    }
    
}
