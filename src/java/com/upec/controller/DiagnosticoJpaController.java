/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.upec.controller;

import com.upec.controller.exceptions.NonexistentEntityException;
import com.upec.controller.exceptions.RollbackFailureException;
import com.upec.model.Diagnostico;
import java.io.Serializable;
import jakarta.persistence.Query;
import jakarta.persistence.EntityNotFoundException;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Root;
import com.upec.model.Empleado;
import com.upec.model.OrdenServicio;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.transaction.UserTransaction;
import java.util.List;

/**
 *
 * @author ACER NITRO V15
 */
public class DiagnosticoJpaController implements Serializable {

    public DiagnosticoJpaController(UserTransaction utx, EntityManagerFactory emf) {
        this.utx = utx;
        this.emf = emf;
    }
    private UserTransaction utx = null;
    private EntityManagerFactory emf = null;

    public EntityManager getEntityManager() {
        return emf.createEntityManager();
    }

    public void create(Diagnostico diagnostico) throws RollbackFailureException, Exception {
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            Empleado IDEmpleadoMecanico = diagnostico.getIDEmpleadoMecanico();
            if (IDEmpleadoMecanico != null) {
                IDEmpleadoMecanico = em.getReference(IDEmpleadoMecanico.getClass(), IDEmpleadoMecanico.getIDEmpleado());
                diagnostico.setIDEmpleadoMecanico(IDEmpleadoMecanico);
            }
            OrdenServicio IDOrdenServicio = diagnostico.getIDOrdenServicio();
            if (IDOrdenServicio != null) {
                IDOrdenServicio = em.getReference(IDOrdenServicio.getClass(), IDOrdenServicio.getIDOrdenServicio());
                diagnostico.setIDOrdenServicio(IDOrdenServicio);
            }
            em.persist(diagnostico);
            if (IDEmpleadoMecanico != null) {
                IDEmpleadoMecanico.getDiagnosticoList().add(diagnostico);
                IDEmpleadoMecanico = em.merge(IDEmpleadoMecanico);
            }
            if (IDOrdenServicio != null) {
                IDOrdenServicio.getDiagnosticoList().add(diagnostico);
                IDOrdenServicio = em.merge(IDOrdenServicio);
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

    public void edit(Diagnostico diagnostico) throws NonexistentEntityException, RollbackFailureException, Exception {
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            Diagnostico persistentDiagnostico = em.find(Diagnostico.class, diagnostico.getIDDiagnostico());
            Empleado IDEmpleadoMecanicoOld = persistentDiagnostico.getIDEmpleadoMecanico();
            Empleado IDEmpleadoMecanicoNew = diagnostico.getIDEmpleadoMecanico();
            OrdenServicio IDOrdenServicioOld = persistentDiagnostico.getIDOrdenServicio();
            OrdenServicio IDOrdenServicioNew = diagnostico.getIDOrdenServicio();
            if (IDEmpleadoMecanicoNew != null) {
                IDEmpleadoMecanicoNew = em.getReference(IDEmpleadoMecanicoNew.getClass(), IDEmpleadoMecanicoNew.getIDEmpleado());
                diagnostico.setIDEmpleadoMecanico(IDEmpleadoMecanicoNew);
            }
            if (IDOrdenServicioNew != null) {
                IDOrdenServicioNew = em.getReference(IDOrdenServicioNew.getClass(), IDOrdenServicioNew.getIDOrdenServicio());
                diagnostico.setIDOrdenServicio(IDOrdenServicioNew);
            }
            diagnostico = em.merge(diagnostico);
            if (IDEmpleadoMecanicoOld != null && !IDEmpleadoMecanicoOld.equals(IDEmpleadoMecanicoNew)) {
                IDEmpleadoMecanicoOld.getDiagnosticoList().remove(diagnostico);
                IDEmpleadoMecanicoOld = em.merge(IDEmpleadoMecanicoOld);
            }
            if (IDEmpleadoMecanicoNew != null && !IDEmpleadoMecanicoNew.equals(IDEmpleadoMecanicoOld)) {
                IDEmpleadoMecanicoNew.getDiagnosticoList().add(diagnostico);
                IDEmpleadoMecanicoNew = em.merge(IDEmpleadoMecanicoNew);
            }
            if (IDOrdenServicioOld != null && !IDOrdenServicioOld.equals(IDOrdenServicioNew)) {
                IDOrdenServicioOld.getDiagnosticoList().remove(diagnostico);
                IDOrdenServicioOld = em.merge(IDOrdenServicioOld);
            }
            if (IDOrdenServicioNew != null && !IDOrdenServicioNew.equals(IDOrdenServicioOld)) {
                IDOrdenServicioNew.getDiagnosticoList().add(diagnostico);
                IDOrdenServicioNew = em.merge(IDOrdenServicioNew);
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
                Integer id = diagnostico.getIDDiagnostico();
                if (findDiagnostico(id) == null) {
                    throw new NonexistentEntityException("The diagnostico with id " + id + " no longer exists.");
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
            Diagnostico diagnostico;
            try {
                diagnostico = em.getReference(Diagnostico.class, id);
                diagnostico.getIDDiagnostico();
            } catch (EntityNotFoundException enfe) {
                throw new NonexistentEntityException("The diagnostico with id " + id + " no longer exists.", enfe);
            }
            Empleado IDEmpleadoMecanico = diagnostico.getIDEmpleadoMecanico();
            if (IDEmpleadoMecanico != null) {
                IDEmpleadoMecanico.getDiagnosticoList().remove(diagnostico);
                IDEmpleadoMecanico = em.merge(IDEmpleadoMecanico);
            }
            OrdenServicio IDOrdenServicio = diagnostico.getIDOrdenServicio();
            if (IDOrdenServicio != null) {
                IDOrdenServicio.getDiagnosticoList().remove(diagnostico);
                IDOrdenServicio = em.merge(IDOrdenServicio);
            }
            em.remove(diagnostico);
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

    public List<Diagnostico> findDiagnosticoEntities() {
        return findDiagnosticoEntities(true, -1, -1);
    }

    public List<Diagnostico> findDiagnosticoEntities(int maxResults, int firstResult) {
        return findDiagnosticoEntities(false, maxResults, firstResult);
    }

    private List<Diagnostico> findDiagnosticoEntities(boolean all, int maxResults, int firstResult) {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            cq.select(cq.from(Diagnostico.class));
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

    public Diagnostico findDiagnostico(Integer id) {
        EntityManager em = getEntityManager();
        try {
            return em.find(Diagnostico.class, id);
        } finally {
            em.close();
        }
    }

    public int getDiagnosticoCount() {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            Root<Diagnostico> rt = cq.from(Diagnostico.class);
            cq.select(em.getCriteriaBuilder().count(rt));
            Query q = em.createQuery(cq);
            return ((Long) q.getSingleResult()).intValue();
        } finally {
            em.close();
        }
    }
    
}
