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
import com.upec.model.Empleado;
import com.upec.model.EstadoTrabajo;
import com.upec.model.Vehiculo;
import com.upec.model.Factura;
import java.util.ArrayList;
import java.util.List;
import com.upec.model.Diagnostico;
import com.upec.model.OrdenServicio;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.transaction.UserTransaction;

/**
 *
 * @author ACER NITRO V15
 */
public class OrdenServicioJpaController implements Serializable {

    public OrdenServicioJpaController(UserTransaction utx, EntityManagerFactory emf) {
        this.utx = utx;
        this.emf = emf;
    }
    private UserTransaction utx = null;
    private EntityManagerFactory emf = null;

    public EntityManager getEntityManager() {
        return emf.createEntityManager();
    }

    public void create(OrdenServicio ordenServicio) throws RollbackFailureException, Exception {
        if (ordenServicio.getFacturaList() == null) {
            ordenServicio.setFacturaList(new ArrayList<Factura>());
        }
        if (ordenServicio.getDiagnosticoList() == null) {
            ordenServicio.setDiagnosticoList(new ArrayList<Diagnostico>());
        }
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            Empleado IDEmpleadoRecepcion = ordenServicio.getIDEmpleadoRecepcion();
            if (IDEmpleadoRecepcion != null) {
                IDEmpleadoRecepcion = em.getReference(IDEmpleadoRecepcion.getClass(), IDEmpleadoRecepcion.getIDEmpleado());
                ordenServicio.setIDEmpleadoRecepcion(IDEmpleadoRecepcion);
            }
            EstadoTrabajo IDEstadoTrabajo = ordenServicio.getIDEstadoTrabajo();
            if (IDEstadoTrabajo != null) {
                IDEstadoTrabajo = em.getReference(IDEstadoTrabajo.getClass(), IDEstadoTrabajo.getIDEstadoTrabajo());
                ordenServicio.setIDEstadoTrabajo(IDEstadoTrabajo);
            }
            Vehiculo IDVehiculo = ordenServicio.getIDVehiculo();
            if (IDVehiculo != null) {
                IDVehiculo = em.getReference(IDVehiculo.getClass(), IDVehiculo.getIDVehiculo());
                ordenServicio.setIDVehiculo(IDVehiculo);
            }
            List<Factura> attachedFacturaList = new ArrayList<Factura>();
            for (Factura facturaListFacturaToAttach : ordenServicio.getFacturaList()) {
                facturaListFacturaToAttach = em.getReference(facturaListFacturaToAttach.getClass(), facturaListFacturaToAttach.getIDFactura());
                attachedFacturaList.add(facturaListFacturaToAttach);
            }
            ordenServicio.setFacturaList(attachedFacturaList);
            List<Diagnostico> attachedDiagnosticoList = new ArrayList<Diagnostico>();
            for (Diagnostico diagnosticoListDiagnosticoToAttach : ordenServicio.getDiagnosticoList()) {
                diagnosticoListDiagnosticoToAttach = em.getReference(diagnosticoListDiagnosticoToAttach.getClass(), diagnosticoListDiagnosticoToAttach.getIDDiagnostico());
                attachedDiagnosticoList.add(diagnosticoListDiagnosticoToAttach);
            }
            ordenServicio.setDiagnosticoList(attachedDiagnosticoList);
            em.persist(ordenServicio);
            if (IDEmpleadoRecepcion != null) {
                IDEmpleadoRecepcion.getOrdenServicioList().add(ordenServicio);
                IDEmpleadoRecepcion = em.merge(IDEmpleadoRecepcion);
            }
            if (IDEstadoTrabajo != null) {
                IDEstadoTrabajo.getOrdenServicioList().add(ordenServicio);
                IDEstadoTrabajo = em.merge(IDEstadoTrabajo);
            }
            if (IDVehiculo != null) {
                IDVehiculo.getOrdenServicioList().add(ordenServicio);
                IDVehiculo = em.merge(IDVehiculo);
            }
            for (Factura facturaListFactura : ordenServicio.getFacturaList()) {
                OrdenServicio oldIDOrdenServicioOfFacturaListFactura = facturaListFactura.getIDOrdenServicio();
                facturaListFactura.setIDOrdenServicio(ordenServicio);
                facturaListFactura = em.merge(facturaListFactura);
                if (oldIDOrdenServicioOfFacturaListFactura != null) {
                    oldIDOrdenServicioOfFacturaListFactura.getFacturaList().remove(facturaListFactura);
                    oldIDOrdenServicioOfFacturaListFactura = em.merge(oldIDOrdenServicioOfFacturaListFactura);
                }
            }
            for (Diagnostico diagnosticoListDiagnostico : ordenServicio.getDiagnosticoList()) {
                OrdenServicio oldIDOrdenServicioOfDiagnosticoListDiagnostico = diagnosticoListDiagnostico.getIDOrdenServicio();
                diagnosticoListDiagnostico.setIDOrdenServicio(ordenServicio);
                diagnosticoListDiagnostico = em.merge(diagnosticoListDiagnostico);
                if (oldIDOrdenServicioOfDiagnosticoListDiagnostico != null) {
                    oldIDOrdenServicioOfDiagnosticoListDiagnostico.getDiagnosticoList().remove(diagnosticoListDiagnostico);
                    oldIDOrdenServicioOfDiagnosticoListDiagnostico = em.merge(oldIDOrdenServicioOfDiagnosticoListDiagnostico);
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

    public void edit(OrdenServicio ordenServicio) throws IllegalOrphanException, NonexistentEntityException, RollbackFailureException, Exception {
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            OrdenServicio persistentOrdenServicio = em.find(OrdenServicio.class, ordenServicio.getIDOrdenServicio());
            Empleado IDEmpleadoRecepcionOld = persistentOrdenServicio.getIDEmpleadoRecepcion();
            Empleado IDEmpleadoRecepcionNew = ordenServicio.getIDEmpleadoRecepcion();
            EstadoTrabajo IDEstadoTrabajoOld = persistentOrdenServicio.getIDEstadoTrabajo();
            EstadoTrabajo IDEstadoTrabajoNew = ordenServicio.getIDEstadoTrabajo();
            Vehiculo IDVehiculoOld = persistentOrdenServicio.getIDVehiculo();
            Vehiculo IDVehiculoNew = ordenServicio.getIDVehiculo();
            List<Factura> facturaListOld = persistentOrdenServicio.getFacturaList();
            List<Factura> facturaListNew = ordenServicio.getFacturaList();
            List<Diagnostico> diagnosticoListOld = persistentOrdenServicio.getDiagnosticoList();
            List<Diagnostico> diagnosticoListNew = ordenServicio.getDiagnosticoList();
            List<String> illegalOrphanMessages = null;
            for (Factura facturaListOldFactura : facturaListOld) {
                if (!facturaListNew.contains(facturaListOldFactura)) {
                    if (illegalOrphanMessages == null) {
                        illegalOrphanMessages = new ArrayList<String>();
                    }
                    illegalOrphanMessages.add("You must retain Factura " + facturaListOldFactura + " since its IDOrdenServicio field is not nullable.");
                }
            }
            for (Diagnostico diagnosticoListOldDiagnostico : diagnosticoListOld) {
                if (!diagnosticoListNew.contains(diagnosticoListOldDiagnostico)) {
                    if (illegalOrphanMessages == null) {
                        illegalOrphanMessages = new ArrayList<String>();
                    }
                    illegalOrphanMessages.add("You must retain Diagnostico " + diagnosticoListOldDiagnostico + " since its IDOrdenServicio field is not nullable.");
                }
            }
            if (illegalOrphanMessages != null) {
                throw new IllegalOrphanException(illegalOrphanMessages);
            }
            if (IDEmpleadoRecepcionNew != null) {
                IDEmpleadoRecepcionNew = em.getReference(IDEmpleadoRecepcionNew.getClass(), IDEmpleadoRecepcionNew.getIDEmpleado());
                ordenServicio.setIDEmpleadoRecepcion(IDEmpleadoRecepcionNew);
            }
            if (IDEstadoTrabajoNew != null) {
                IDEstadoTrabajoNew = em.getReference(IDEstadoTrabajoNew.getClass(), IDEstadoTrabajoNew.getIDEstadoTrabajo());
                ordenServicio.setIDEstadoTrabajo(IDEstadoTrabajoNew);
            }
            if (IDVehiculoNew != null) {
                IDVehiculoNew = em.getReference(IDVehiculoNew.getClass(), IDVehiculoNew.getIDVehiculo());
                ordenServicio.setIDVehiculo(IDVehiculoNew);
            }
            List<Factura> attachedFacturaListNew = new ArrayList<Factura>();
            for (Factura facturaListNewFacturaToAttach : facturaListNew) {
                facturaListNewFacturaToAttach = em.getReference(facturaListNewFacturaToAttach.getClass(), facturaListNewFacturaToAttach.getIDFactura());
                attachedFacturaListNew.add(facturaListNewFacturaToAttach);
            }
            facturaListNew = attachedFacturaListNew;
            ordenServicio.setFacturaList(facturaListNew);
            List<Diagnostico> attachedDiagnosticoListNew = new ArrayList<Diagnostico>();
            for (Diagnostico diagnosticoListNewDiagnosticoToAttach : diagnosticoListNew) {
                diagnosticoListNewDiagnosticoToAttach = em.getReference(diagnosticoListNewDiagnosticoToAttach.getClass(), diagnosticoListNewDiagnosticoToAttach.getIDDiagnostico());
                attachedDiagnosticoListNew.add(diagnosticoListNewDiagnosticoToAttach);
            }
            diagnosticoListNew = attachedDiagnosticoListNew;
            ordenServicio.setDiagnosticoList(diagnosticoListNew);
            ordenServicio = em.merge(ordenServicio);
            if (IDEmpleadoRecepcionOld != null && !IDEmpleadoRecepcionOld.equals(IDEmpleadoRecepcionNew)) {
                IDEmpleadoRecepcionOld.getOrdenServicioList().remove(ordenServicio);
                IDEmpleadoRecepcionOld = em.merge(IDEmpleadoRecepcionOld);
            }
            if (IDEmpleadoRecepcionNew != null && !IDEmpleadoRecepcionNew.equals(IDEmpleadoRecepcionOld)) {
                IDEmpleadoRecepcionNew.getOrdenServicioList().add(ordenServicio);
                IDEmpleadoRecepcionNew = em.merge(IDEmpleadoRecepcionNew);
            }
            if (IDEstadoTrabajoOld != null && !IDEstadoTrabajoOld.equals(IDEstadoTrabajoNew)) {
                IDEstadoTrabajoOld.getOrdenServicioList().remove(ordenServicio);
                IDEstadoTrabajoOld = em.merge(IDEstadoTrabajoOld);
            }
            if (IDEstadoTrabajoNew != null && !IDEstadoTrabajoNew.equals(IDEstadoTrabajoOld)) {
                IDEstadoTrabajoNew.getOrdenServicioList().add(ordenServicio);
                IDEstadoTrabajoNew = em.merge(IDEstadoTrabajoNew);
            }
            if (IDVehiculoOld != null && !IDVehiculoOld.equals(IDVehiculoNew)) {
                IDVehiculoOld.getOrdenServicioList().remove(ordenServicio);
                IDVehiculoOld = em.merge(IDVehiculoOld);
            }
            if (IDVehiculoNew != null && !IDVehiculoNew.equals(IDVehiculoOld)) {
                IDVehiculoNew.getOrdenServicioList().add(ordenServicio);
                IDVehiculoNew = em.merge(IDVehiculoNew);
            }
            for (Factura facturaListNewFactura : facturaListNew) {
                if (!facturaListOld.contains(facturaListNewFactura)) {
                    OrdenServicio oldIDOrdenServicioOfFacturaListNewFactura = facturaListNewFactura.getIDOrdenServicio();
                    facturaListNewFactura.setIDOrdenServicio(ordenServicio);
                    facturaListNewFactura = em.merge(facturaListNewFactura);
                    if (oldIDOrdenServicioOfFacturaListNewFactura != null && !oldIDOrdenServicioOfFacturaListNewFactura.equals(ordenServicio)) {
                        oldIDOrdenServicioOfFacturaListNewFactura.getFacturaList().remove(facturaListNewFactura);
                        oldIDOrdenServicioOfFacturaListNewFactura = em.merge(oldIDOrdenServicioOfFacturaListNewFactura);
                    }
                }
            }
            for (Diagnostico diagnosticoListNewDiagnostico : diagnosticoListNew) {
                if (!diagnosticoListOld.contains(diagnosticoListNewDiagnostico)) {
                    OrdenServicio oldIDOrdenServicioOfDiagnosticoListNewDiagnostico = diagnosticoListNewDiagnostico.getIDOrdenServicio();
                    diagnosticoListNewDiagnostico.setIDOrdenServicio(ordenServicio);
                    diagnosticoListNewDiagnostico = em.merge(diagnosticoListNewDiagnostico);
                    if (oldIDOrdenServicioOfDiagnosticoListNewDiagnostico != null && !oldIDOrdenServicioOfDiagnosticoListNewDiagnostico.equals(ordenServicio)) {
                        oldIDOrdenServicioOfDiagnosticoListNewDiagnostico.getDiagnosticoList().remove(diagnosticoListNewDiagnostico);
                        oldIDOrdenServicioOfDiagnosticoListNewDiagnostico = em.merge(oldIDOrdenServicioOfDiagnosticoListNewDiagnostico);
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
                Integer id = ordenServicio.getIDOrdenServicio();
                if (findOrdenServicio(id) == null) {
                    throw new NonexistentEntityException("The ordenServicio with id " + id + " no longer exists.");
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
            OrdenServicio ordenServicio;
            try {
                ordenServicio = em.getReference(OrdenServicio.class, id);
                ordenServicio.getIDOrdenServicio();
            } catch (EntityNotFoundException enfe) {
                throw new NonexistentEntityException("The ordenServicio with id " + id + " no longer exists.", enfe);
            }
            List<String> illegalOrphanMessages = null;
            List<Factura> facturaListOrphanCheck = ordenServicio.getFacturaList();
            for (Factura facturaListOrphanCheckFactura : facturaListOrphanCheck) {
                if (illegalOrphanMessages == null) {
                    illegalOrphanMessages = new ArrayList<String>();
                }
                illegalOrphanMessages.add("This OrdenServicio (" + ordenServicio + ") cannot be destroyed since the Factura " + facturaListOrphanCheckFactura + " in its facturaList field has a non-nullable IDOrdenServicio field.");
            }
            List<Diagnostico> diagnosticoListOrphanCheck = ordenServicio.getDiagnosticoList();
            for (Diagnostico diagnosticoListOrphanCheckDiagnostico : diagnosticoListOrphanCheck) {
                if (illegalOrphanMessages == null) {
                    illegalOrphanMessages = new ArrayList<String>();
                }
                illegalOrphanMessages.add("This OrdenServicio (" + ordenServicio + ") cannot be destroyed since the Diagnostico " + diagnosticoListOrphanCheckDiagnostico + " in its diagnosticoList field has a non-nullable IDOrdenServicio field.");
            }
            if (illegalOrphanMessages != null) {
                throw new IllegalOrphanException(illegalOrphanMessages);
            }
            Empleado IDEmpleadoRecepcion = ordenServicio.getIDEmpleadoRecepcion();
            if (IDEmpleadoRecepcion != null) {
                IDEmpleadoRecepcion.getOrdenServicioList().remove(ordenServicio);
                IDEmpleadoRecepcion = em.merge(IDEmpleadoRecepcion);
            }
            EstadoTrabajo IDEstadoTrabajo = ordenServicio.getIDEstadoTrabajo();
            if (IDEstadoTrabajo != null) {
                IDEstadoTrabajo.getOrdenServicioList().remove(ordenServicio);
                IDEstadoTrabajo = em.merge(IDEstadoTrabajo);
            }
            Vehiculo IDVehiculo = ordenServicio.getIDVehiculo();
            if (IDVehiculo != null) {
                IDVehiculo.getOrdenServicioList().remove(ordenServicio);
                IDVehiculo = em.merge(IDVehiculo);
            }
            em.remove(ordenServicio);
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

    public List<OrdenServicio> findOrdenServicioEntities() {
        return findOrdenServicioEntities(true, -1, -1);
    }

    public List<OrdenServicio> findOrdenServicioEntities(int maxResults, int firstResult) {
        return findOrdenServicioEntities(false, maxResults, firstResult);
    }

    private List<OrdenServicio> findOrdenServicioEntities(boolean all, int maxResults, int firstResult) {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            cq.select(cq.from(OrdenServicio.class));
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

    public OrdenServicio findOrdenServicio(Integer id) {
        EntityManager em = getEntityManager();
        try {
            return em.find(OrdenServicio.class, id);
        } finally {
            em.close();
        }
    }

    public int getOrdenServicioCount() {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            Root<OrdenServicio> rt = cq.from(OrdenServicio.class);
            cq.select(em.getCriteriaBuilder().count(rt));
            Query q = em.createQuery(cq);
            return ((Long) q.getSingleResult()).intValue();
        } finally {
            em.close();
        }
    }
    
}
