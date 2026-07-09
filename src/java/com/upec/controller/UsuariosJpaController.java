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
import com.upec.model.Roles;
import com.upec.model.Empleado;
import com.upec.model.Usuarios;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.transaction.UserTransaction;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author ACER NITRO V15
 */
public class UsuariosJpaController implements Serializable {

    public UsuariosJpaController(UserTransaction utx, EntityManagerFactory emf) {
        this.utx = utx;
        this.emf = emf;
    }
    private UserTransaction utx = null;
    private EntityManagerFactory emf = null;

    public EntityManager getEntityManager() {
        return emf.createEntityManager();
    }

    public void create(Usuarios usuarios) throws RollbackFailureException, Exception {
        if (usuarios.getEmpleadoList() == null) {
            usuarios.setEmpleadoList(new ArrayList<Empleado>());
        }
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            Roles IDRol = usuarios.getIDRol();
            if (IDRol != null) {
                IDRol = em.getReference(IDRol.getClass(), IDRol.getIDRol());
                usuarios.setIDRol(IDRol);
            }
            List<Empleado> attachedEmpleadoList = new ArrayList<Empleado>();
            for (Empleado empleadoListEmpleadoToAttach : usuarios.getEmpleadoList()) {
                empleadoListEmpleadoToAttach = em.getReference(empleadoListEmpleadoToAttach.getClass(), empleadoListEmpleadoToAttach.getIDEmpleado());
                attachedEmpleadoList.add(empleadoListEmpleadoToAttach);
            }
            usuarios.setEmpleadoList(attachedEmpleadoList);
            em.persist(usuarios);
            if (IDRol != null) {
                IDRol.getUsuariosList().add(usuarios);
                IDRol = em.merge(IDRol);
            }
            for (Empleado empleadoListEmpleado : usuarios.getEmpleadoList()) {
                Usuarios oldIDUsuarioOfEmpleadoListEmpleado = empleadoListEmpleado.getIDUsuario();
                empleadoListEmpleado.setIDUsuario(usuarios);
                empleadoListEmpleado = em.merge(empleadoListEmpleado);
                if (oldIDUsuarioOfEmpleadoListEmpleado != null) {
                    oldIDUsuarioOfEmpleadoListEmpleado.getEmpleadoList().remove(empleadoListEmpleado);
                    oldIDUsuarioOfEmpleadoListEmpleado = em.merge(oldIDUsuarioOfEmpleadoListEmpleado);
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

    public void edit(Usuarios usuarios) throws NonexistentEntityException, RollbackFailureException, Exception {
        EntityManager em = null;
        try {
            utx.begin();
            em = getEntityManager();
            Usuarios persistentUsuarios = em.find(Usuarios.class, usuarios.getIDUsuario());
            Roles IDRolOld = persistentUsuarios.getIDRol();
            Roles IDRolNew = usuarios.getIDRol();
            List<Empleado> empleadoListOld = persistentUsuarios.getEmpleadoList();
            List<Empleado> empleadoListNew = usuarios.getEmpleadoList();
            if (IDRolNew != null) {
                IDRolNew = em.getReference(IDRolNew.getClass(), IDRolNew.getIDRol());
                usuarios.setIDRol(IDRolNew);
            }
            List<Empleado> attachedEmpleadoListNew = new ArrayList<Empleado>();
            for (Empleado empleadoListNewEmpleadoToAttach : empleadoListNew) {
                empleadoListNewEmpleadoToAttach = em.getReference(empleadoListNewEmpleadoToAttach.getClass(), empleadoListNewEmpleadoToAttach.getIDEmpleado());
                attachedEmpleadoListNew.add(empleadoListNewEmpleadoToAttach);
            }
            empleadoListNew = attachedEmpleadoListNew;
            usuarios.setEmpleadoList(empleadoListNew);
            usuarios = em.merge(usuarios);
            if (IDRolOld != null && !IDRolOld.equals(IDRolNew)) {
                IDRolOld.getUsuariosList().remove(usuarios);
                IDRolOld = em.merge(IDRolOld);
            }
            if (IDRolNew != null && !IDRolNew.equals(IDRolOld)) {
                IDRolNew.getUsuariosList().add(usuarios);
                IDRolNew = em.merge(IDRolNew);
            }
            for (Empleado empleadoListOldEmpleado : empleadoListOld) {
                if (!empleadoListNew.contains(empleadoListOldEmpleado)) {
                    empleadoListOldEmpleado.setIDUsuario(null);
                    empleadoListOldEmpleado = em.merge(empleadoListOldEmpleado);
                }
            }
            for (Empleado empleadoListNewEmpleado : empleadoListNew) {
                if (!empleadoListOld.contains(empleadoListNewEmpleado)) {
                    Usuarios oldIDUsuarioOfEmpleadoListNewEmpleado = empleadoListNewEmpleado.getIDUsuario();
                    empleadoListNewEmpleado.setIDUsuario(usuarios);
                    empleadoListNewEmpleado = em.merge(empleadoListNewEmpleado);
                    if (oldIDUsuarioOfEmpleadoListNewEmpleado != null && !oldIDUsuarioOfEmpleadoListNewEmpleado.equals(usuarios)) {
                        oldIDUsuarioOfEmpleadoListNewEmpleado.getEmpleadoList().remove(empleadoListNewEmpleado);
                        oldIDUsuarioOfEmpleadoListNewEmpleado = em.merge(oldIDUsuarioOfEmpleadoListNewEmpleado);
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
                Integer id = usuarios.getIDUsuario();
                if (findUsuarios(id) == null) {
                    throw new NonexistentEntityException("The usuarios with id " + id + " no longer exists.");
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
            Usuarios usuarios;
            try {
                usuarios = em.getReference(Usuarios.class, id);
                usuarios.getIDUsuario();
            } catch (EntityNotFoundException enfe) {
                throw new NonexistentEntityException("The usuarios with id " + id + " no longer exists.", enfe);
            }
            Roles IDRol = usuarios.getIDRol();
            if (IDRol != null) {
                IDRol.getUsuariosList().remove(usuarios);
                IDRol = em.merge(IDRol);
            }
            List<Empleado> empleadoList = usuarios.getEmpleadoList();
            for (Empleado empleadoListEmpleado : empleadoList) {
                empleadoListEmpleado.setIDUsuario(null);
                empleadoListEmpleado = em.merge(empleadoListEmpleado);
            }
            em.remove(usuarios);
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

    public List<Usuarios> findUsuariosEntities() {
        return findUsuariosEntities(true, -1, -1);
    }

    public List<Usuarios> findUsuariosEntities(int maxResults, int firstResult) {
        return findUsuariosEntities(false, maxResults, firstResult);
    }

    private List<Usuarios> findUsuariosEntities(boolean all, int maxResults, int firstResult) {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            cq.select(cq.from(Usuarios.class));
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

    public Usuarios findUsuarios(Integer id) {
        EntityManager em = getEntityManager();
        try {
            return em.find(Usuarios.class, id);
        } finally {
            em.close();
        }
    }

    public int getUsuariosCount() {
        EntityManager em = getEntityManager();
        try {
            CriteriaQuery cq = em.getCriteriaBuilder().createQuery();
            Root<Usuarios> rt = cq.from(Usuarios.class);
            cq.select(em.getCriteriaBuilder().count(rt));
            Query q = em.createQuery(cq);
            return ((Long) q.getSingleResult()).intValue();
        } finally {
            em.close();
        }
    }
    
}
