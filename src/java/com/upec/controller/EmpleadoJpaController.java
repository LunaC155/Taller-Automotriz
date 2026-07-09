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
import com.upec.model.Usuarios;
import com.upec.model.OrdenServicio;
import java.util.ArrayList;
import java.util.List;
import com.upec.model.Diagnostico;
import com.upec.model.Empleado;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.transaction.UserTransaction;

/**
 *
 * @author ACER NITRO V15
 */
public class EmpleadoJpaController implements Serializable {

    public EmpleadoJpaController(UserTransaction utx, EntityManagerFactory emf) {
        this.utx = utx;
        this.emf = emf;
    }
    private UserTransaction utx = null;
    private EntityManagerFactory emf = null;

    public EntityManager getEntityManager() {
        return emf.createEntityManager();
    }

    public void create(Empleado empleado) throws RollbackFailureException, Exception {
        if (empleado.getOrdenServicioList() == null) {
            empleado.setOrdenServicioList(new ArrayList<OrdenServicio>());
        }
        if (empleado.getDiagnosticoList() == null) {
            empleado.setDiagnosticoList(new ArrayList<Diagnostico>());
        }
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            Usuarios IDUsuario = empleado.getIDUsuario();
            if (IDUsuario != null) {
                IDUsuario = em.getReference(IDUsuario.getClass(), IDUsuario.getIDUsuario());
                empleado.setIDUsuario(IDUsuario);
            }
            List<OrdenServicio> attachedOrdenServicioList = new ArrayList<OrdenServicio>();
            for (OrdenServicio ordenServicioListOrdenServicioToAttach : empleado.getOrdenServicioList()) {
                ordenServicioListOrdenServicioToAttach = em.getReference(ordenServicioListOrdenServicioToAttach.getClass(), ordenServicioListOrdenServicioToAttach.getIDOrdenServicio());
                attachedOrdenServicioList.add(ordenServicioListOrdenServicioToAttach);
            }
            empleado.setOrdenServicioList(attachedOrdenServicioList);
            List<Diagnostico> attachedDiagnosticoList = new ArrayList<Diagnostico>();
            for (Diagnostico diagnosticoListDiagnosticoToAttach : empleado.getDiagnosticoList()) {
                diagnosticoListDiagnosticoToAttach = em.getReference(diagnosticoListDiagnosticoToAttach.getClass(), diagnosticoListDiagnosticoToAttach.getIDDiagnostico());
                attachedDiagnosticoList.add(diagnosticoListDiagnosticoToAttach);
            }
            empleado.setDiagnosticoList(attachedDiagnosticoList);
            em.persist(empleado);
            if (IDUsuario != null) {
                IDUsuario.getEmpleadoList().add(empleado);
                IDUsuario = em.merge(IDUsuario);
            }
            for (OrdenServicio ordenServicioListOrdenServicio : empleado.getOrdenServicioList()) {
                Empleado oldIDEmpleadoRecepcionOfOrdenServicioListOrdenServicio = ordenServicioListOrdenServicio.getIDEmpleadoRecepcion();
                ordenServicioListOrdenServicio.setIDEmpleadoRecepcion(empleado);
                ordenServicioListOrdenServicio = em.merge(ordenServicioListOrdenServicio);
                if (oldIDEmpleadoRecepcionOfOrdenServicioListOrdenServicio != null) {
                    oldIDEmpleadoRecepcionOfOrdenServicioListOrdenServicio.getOrdenServicioList().remove(ordenServicioListOrdenServicio);
                    oldIDEmpleadoRecepcionOfOrdenServicioListOrdenServicio = em.merge(oldIDEmpleadoRecepcionOfOrdenServicioListOrdenServicio);
                }
            }
            for (Diagnostico diagnosticoListDiagnostico : empleado.getDiagnosticoList()) {
                Empleado oldIDEmpleadoMecanicoOfDiagnosticoListDiagnostico = diagnosticoListDiagnostico.getIDEmpleadoMecanico();
                diagnosticoListDiagnostico.setIDEmpleadoMecanico(empleado);
                diagnosticoListDiagnostico = em.merge(diagnosticoListDiagnostico);
                if (oldIDEmpleadoMecanicoOfDiagnosticoListDiagnostico != null) {
                    oldIDEmpleadoMecanicoOfDiagnosticoListDiagnostico.getDiagnosticoList().remove(diagnosticoListDiagnostico);
                    oldIDEmpleadoMecanicoOfDiagnosticoListDiagnostico = em.merge(oldIDEmpleadoMecanicoOfDiagnosticoListDiagnostico);
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

    public void edit(Empleado empleado) throws IllegalOrphanException, NonexistentEntityException, RollbackFailureException, Exception {
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            Empleado persistentEmpleado = em.find(Empleado.class, empleado.getIDEmpleado());
            Usuarios IDUsuarioOld = persistentEmpleado.getIDUsuario();
            Usuarios IDUsuarioNew = empleado.getIDUsuario();
            List<OrdenServicio> ordenServicioListOld = persistentEmpleado.getOrdenServicioList();
            List<OrdenServicio> ordenServicioListNew = empleado.getOrdenServicioList();
            List<Diagnostico> diagnosticoListOld = persistentEmpleado.getDiagnosticoList();
            List<Diagnostico> diagnosticoListNew = empleado.getDiagnosticoList();
            List<String> illegalOrphanMessages = null;
            for (OrdenServicio ordenServicioListOldOrdenServicio : ordenServicioListOld) {
                if (!ordenServicioListNew.contains(ordenServicioListOldOrdenServicio)) {
                    if (illegalOrphanMessages == null) {
                        illegalOrphanMessages = new ArrayList<String>();
                    }
                    illegalOrphanMessages.add("You must retain OrdenServicio " + ordenServicioListOldOrdenServicio + " since its IDEmpleadoRecepcion field is not nullable.");
                }
            }
            for (Diagnostico diagnosticoListOldDiagnostico : diagnosticoListOld) {
                if (!diagnosticoListNew.contains(diagnosticoListOldDiagnostico)) {
                    if (illegalOrphanMessages == null) {
                        illegalOrphanMessages = new ArrayList<String>();
                    }
                    illegalOrphanMessages.add("You must retain Diagnostico " + diagnosticoListOldDiagnostico + " since its IDEmpleadoMecanico field is not nullable.");
                }
            }
            if (illegalOrphanMessages != null) {
                throw new IllegalOrphanException(illegalOrphanMessages);
            }
            if (IDUsuarioNew != null) {
                IDUsuarioNew = em.getReference(IDUsuarioNew.getClass(), IDUsuarioNew.getIDUsuario());
                empleado.setIDUsuario(IDUsuarioNew);
            }
            List<OrdenServicio> attachedOrdenServicioListNew = new ArrayList<OrdenServicio>();
            for (OrdenServicio ordenServicioListNewOrdenServicioToAttach : ordenServicioListNew) {
                ordenServicioListNewOrdenServicioToAttach = em.getReference(ordenServicioListNewOrdenServicioToAttach.getClass(), ordenServicioListNewOrdenServicioToAttach.getIDOrdenServicio());
                attachedOrdenServicioListNew.add(ordenServicioListNewOrdenServicioToAttach);
            }
            ordenServicioListNew = attachedOrdenServicioListNew;
            empleado.setOrdenServicioList(ordenServicioListNew);
            List<Diagnostico> attachedDiagnosticoListNew = new ArrayList<Diagnostico>();
            for (Diagnostico diagnosticoListNewDiagnosticoToAttach : diagnosticoListNew) {
                diagnosticoListNewDiagnosticoToAttach = em.getReference(diagnosticoListNewDiagnosticoToAttach.getClass(), diagnosticoListNewDiagnosticoToAttach.getIDDiagnostico());
                attachedDiagnosticoListNew.add(diagnosticoListNewDiagnosticoToAttach);
            }
            diagnosticoListNew = attachedDiagnosticoListNew;
            empleado.setDiagnosticoList(diagnosticoListNew);
            empleado = em.merge(empleado);
            if (IDUsuarioOld != null && !IDUsuarioOld.equals(IDUsuarioNew)) {
                IDUsuarioOld.getEmpleadoList().remove(empleado);
                IDUsuarioOld = em.merge(IDUsuarioOld);
            }
            if (IDUsuarioNew != null && !IDUsuarioNew.equals(IDUsuarioOld)) {
                IDUsuarioNew.getEmpleadoList().add(empleado);
                IDUsuarioNew = em.merge(IDUsuarioNew);
            }
            for (OrdenServicio ordenServicioListNewOrdenServicio : ordenServicioListNew) {
                if (!ordenServicioListOld.contains(ordenServicioListNewOrdenServicio)) {
                    Empleado oldIDEmpleadoRecepcionOfOrdenServicioListNewOrdenServicio = ordenServicioListNewOrdenServicio.getIDEmpleadoRecepcion();
                    ordenServicioListNewOrdenServicio.setIDEmpleadoRecepcion(empleado);
                    ordenServicioListNewOrdenServicio = em.merge(ordenServicioListNewOrdenServicio);
                    if (oldIDEmpleadoRecepcionOfOrdenServicioListNewOrdenServicio != null && !oldIDEmpleadoRecepcionOfOrdenServicioListNewOrdenServicio.equals(empleado)) {
                        oldIDEmpleadoRecepcionOfOrdenServicioListNewOrdenServicio.getOrdenServicioList().remove(ordenServicioListNewOrdenServicio);
                        oldIDEmpleadoRecepcionOfOrdenServicioListNewOrdenServicio = em.merge(oldIDEmpleadoRecepcionOfOrdenServicioListNewOrdenServicio);
                    }
                }
            }
            for (Diagnostico diagnosticoListNewDiagnostico : diagnosticoListNew) {
                if (!diagnosticoListOld.contains(diagnosticoListNewDiagnostico)) {
                    Empleado oldIDEmpleadoMecanicoOfDiagnosticoListNewDiagnostico = diagnosticoListNewDiagnostico.getIDEmpleadoMecanico();
                    diagnosticoListNewDiagnostico.setIDEmpleadoMecanico(empleado);
                    diagnosticoListNewDiagnostico = em.merge(diagnosticoListNewDiagnostico);
                    if (oldIDEmpleadoMecanicoOfDiagnosticoListNewDiagnostico != null && !oldIDEmpleadoMecanicoOfDiagnosticoListNewDiagnostico.equals(empleado)) {
                        oldIDEmpleadoMecanicoOfDiagnosticoListNewDiagnostico.getDiagnosticoList().remove(diagnosticoListNewDiagnostico);
                        oldIDEmpleadoMecanicoOfDiagnosticoListNewDiagnostico = em.merge(oldIDEmpleadoMecanicoOfDiagnosticoListNewDiagnostico);
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
                Integer id = empleado.getIDEmpleado();
                if (findEmpleado(id) == null) {
                    throw new NonexistentEntityException("The empleado with id " + id + " no longer exists.");
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
            Empleado empleado;
            try {
                empleado = em.getReference(Empleado.class, id);
                empleado.getIDEmpleado();
            } catch (EntityNotFoundException enfe) {
                throw new NonexistentEntityException("The empleado with id " + id + " no longer exists.", enfe);
            }
            List<String> illegalOrphanMessages = null;
            List<OrdenServicio> ordenServicioListOrphanCheck = empleado.getOrdenServicioList();
            for (OrdenServicio ordenServicioListOrphanCheckOrdenServicio : ordenServicioListOrphanCheck) {
                if (illegalOrphanMessages == null) {
                    illegalOrphanMessages = new ArrayList<String>();
                }
                illegalOrphanMessages.add("This Empleado (" + empleado + ") cannot be destroyed since the OrdenServicio " + ordenServicioListOrphanCheckOrdenServicio + " in its ordenServicioList field has a non-nullable IDEmpleadoRecepcion field.");
            }
            List<Diagnostico> diagnosticoListOrphanCheck = empleado.getDiagnosticoList();
            for (Diagnostico diagnosticoListOrphanCheckDiagnostico : diagnosticoListOrphanCheck) {
                if (illegalOrphanMessages == null) {
                    illegalOrphanMessages = new ArrayList<String>();
                }
                illegalOrphanMessages.add("This Empleado (" + empleado + ") cannot be destroyed since the Diagnostico " + diagnosticoListOrphanCheckDiagnostico + " in its diagnosticoList field has a non-nullable IDEmpleadoMecanico field.");
            }
            if (illegalOrphanMessages != null) {
                throw new IllegalOrphanException(illegalOrphanMessages);
            }
            Usuarios IDUsuario = empleado.getIDUsuario();
            if (IDUsuario != null) {
                IDUsuario.getEmpleadoList().remove(empleado);
                IDUsuario = em.merge(IDUsuario);
            }
            em.remove(empleado);
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

    public List<Empleado> findEmpleadoEntities() {
        return findEmpleadoEntities(true, -1, -1);
    }

    public List<Empleado> findEmpleadoEntities(int maxResults, int firstResult) {
        return findEmpleadoEntities(false, maxResults, firstResult);
    }

    private List<Empleado> findEmpleadoEntities(boolean all, int maxResults, int firstResult) {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            cq.select(cq.from(Empleado.class));
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

    public Empleado findEmpleado(Integer id) {
        EntityManager em = getEntityManager();
        try {
            return em.find(Empleado.class, id);
        } finally {
            em.close();
        }
    }

    public int getEmpleadoCount() {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            Root<Empleado> rt = cq.from(Empleado.class);
            cq.select(em.getCriteriaBuilder().count(rt));
            Query q = em.createQuery(cq);
            return ((Long) q.getSingleResult()).intValue();
        } finally {
            em.close();
        }
    }
    
}
