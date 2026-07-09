package com.upec.dao;

import com.upec.model.Cliente;
import com.upec.model.Vehiculo;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;
import java.util.Date;
import java.util.List;

@Stateless
public class ClienteDAO {
    
    @PersistenceContext(unitName = "taller_automotrizPU")
    private EntityManager em;

    // CRUD Básico
    
    public List<Cliente> listarClientes() {
        try {
            return em.createQuery("SELECT c FROM Cliente c", Cliente.class).getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando clientes", e);
        }
    }

    public Cliente obtenerClientePorId(int id) {
        try {
            return em.find(Cliente.class, id);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo cliente por ID", e);
        }
    }

    @Transactional
    public boolean crearCliente(Cliente cliente) {
        try {
            em.persist(cliente);
            return true;
        } catch (Exception e) {
            throw new RuntimeException("Error creando cliente", e);
        }
    }

    @Transactional
    public boolean actualizarCliente(Cliente cliente) {
        try {
            em.merge(cliente);
            return true;
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando cliente", e);
        }
    }

    @Transactional
    public boolean eliminarCliente(int id) {
        try {
            Cliente cliente = em.find(Cliente.class, id);
            if (cliente != null) {
                em.remove(cliente);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error eliminando cliente", e);
        }
    }


    public List<Cliente> buscarClientesPorNombre(String nombre) {
        try {
            return em.createQuery("SELECT c FROM Cliente c WHERE c.nombre LIKE :nombre OR c.apellido LIKE :nombre", Cliente.class)
                     .setParameter("nombre", "%" + nombre + "%")
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando clientes por nombre", e);
        }
    }

    public List<Cliente> buscarClientesPorEmail(String email) {
        try {
            return em.createQuery("SELECT c FROM Cliente c WHERE c.email LIKE :email", Cliente.class)
                     .setParameter("email", "%" + email + "%")
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando clientes por email", e);
        }
    }

    public List<Cliente> buscarClientesPorTelefono(String telefono) {
        try {
            return em.createQuery("SELECT c FROM Cliente c WHERE c.telefono LIKE :telefono", Cliente.class)
                     .setParameter("telefono", "%" + telefono + "%")
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando clientes por teléfono", e);
        }
    }

    public List<Cliente> filtrarClientesPorFechaRegistro(Date fechaInicio, Date fechaFin) {
        try {
            return em.createQuery("SELECT c FROM Cliente c WHERE c.fechaRegistro BETWEEN :fechaInicio AND :fechaFin", Cliente.class)
                     .setParameter("fechaInicio", fechaInicio)
                     .setParameter("fechaFin", fechaFin)
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error filtrando clientes por fecha de registro", e);
        }
    }

    // Para Recepcionista
    
    public Cliente obtenerClienteConVehiculos(int idCliente) {
        try {
            // CORRECCIÓN: Usando el nombre correcto de la relación según tu entidad
            return em.createQuery("SELECT c FROM Cliente c LEFT JOIN FETCH c.vehiculoList WHERE c.iDCliente = :id", Cliente.class)
                     .setParameter("id", idCliente)
                     .getSingleResult();
        } catch (Exception e) {
            return null;
        }
    }

    public List<Cliente> listarClientesActivos() {
        try {
            // CORRECCIÓN: Clientes que tienen al menos un vehículo registrado
            return em.createQuery("SELECT DISTINCT c FROM Cliente c JOIN c.vehiculoList v", Cliente.class)
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando clientes activos", e);
        }
    }

    // Para Admin (Reportes)
    
    public int contarTotalClientes() {
        try {
            Long count = em.createQuery("SELECT COUNT(c) FROM Cliente c", Long.class)
                          .getSingleResult();
            return count != null ? count.intValue() : 0;
        } catch (Exception e) {
            throw new RuntimeException("Error contando total de clientes", e);
        }
    }

    public int contarClientesNuevosEsteMes() {
        try {
            Date primerDiaMes = obtenerPrimerDiaMes();
            Date ultimoDiaMes = obtenerUltimoDiaMes();

            Long count = em.createQuery("SELECT COUNT(c) FROM Cliente c WHERE c.fechaRegistro BETWEEN :inicioMes AND :finMes", Long.class)
                          .setParameter("inicioMes", primerDiaMes)
                          .setParameter("finMes", ultimoDiaMes)
                          .getSingleResult();
            return count != null ? count.intValue() : 0;
        } catch (Exception e) {
            throw new RuntimeException("Error contando clientes nuevos este mes", e);
        }
    }

    public List<Object[]> obtenerEstadisticasClientes() {
        try {
            Date inicioMes = obtenerPrimerDiaMes();
            
            return em.createQuery("SELECT " +
                                 "COUNT(c) as totalClientes, " +
                                 "SUM(CASE WHEN c.fechaRegistro >= :inicioMes THEN 1 ELSE 0 END) as nuevosEsteMes, " +
                                 "(SELECT COUNT(DISTINCT v.iDCliente.iDCliente) FROM Vehiculo v) as clientesConVehiculos " +
                                 "FROM Cliente c", Object[].class)
                     .setParameter("inicioMes", inicioMes)
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estadísticas de clientes", e);
        }
    }

    // Métodos auxiliares
    
    private Date obtenerPrimerDiaMes() {
        java.util.Calendar calendar = java.util.Calendar.getInstance();
        calendar.set(java.util.Calendar.DAY_OF_MONTH, 1);
        calendar.set(java.util.Calendar.HOUR_OF_DAY, 0);
        calendar.set(java.util.Calendar.MINUTE, 0);
        calendar.set(java.util.Calendar.SECOND, 0);
        calendar.set(java.util.Calendar.MILLISECOND, 0);
        return calendar.getTime();
    }
    
    private Date obtenerUltimoDiaMes() {
        java.util.Calendar calendar = java.util.Calendar.getInstance();
        calendar.add(java.util.Calendar.MONTH, 1);
        calendar.set(java.util.Calendar.DAY_OF_MONTH, 1);
        calendar.add(java.util.Calendar.DAY_OF_MONTH, -1);
        calendar.set(java.util.Calendar.HOUR_OF_DAY, 23);
        calendar.set(java.util.Calendar.MINUTE, 59);
        calendar.set(java.util.Calendar.SECOND, 59);
        calendar.set(java.util.Calendar.MILLISECOND, 999);
        return calendar.getTime();
    }

    // Métodos existentes que pueden ser útiles (mantenidos por compatibilidad)
    
    public boolean emailExists(String email) {
        try {
            Long count = em.createQuery("SELECT COUNT(c) FROM Cliente c WHERE c.email = :email", Long.class)
                           .setParameter("email", email)
                           .getSingleResult();
            return count > 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando existencia de email", e);
        }
    }

    public List<Cliente> findClientesRecientes(int limite) {
        try {
            return em.createQuery("SELECT c FROM Cliente c ORDER BY c.fechaRegistro DESC", Cliente.class)
                     .setMaxResults(limite)
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando clientes recientes", e);
        }
    }

    // CORRECCIÓN: Método para buscar cliente por cualquier criterio (nombre, email, teléfono)
    public List<Cliente> buscarClientePorCriterio(String criterio) {
        try {
            return em.createQuery("SELECT c FROM Cliente c WHERE " +
                                 "c.nombre LIKE :criterio OR " +
                                 "c.apellido LIKE :criterio OR " +
                                 "c.email LIKE :criterio OR " +
                                 "c.telefono LIKE :criterio", Cliente.class)
                     .setParameter("criterio", "%" + criterio + "%")
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando cliente por criterio", e);
        }
    }

    // CORRECCIÓN: Método para verificar si existe cliente con email
    public boolean existeClienteConEmail(String email) {
        try {
            Long count = em.createQuery("SELECT COUNT(c) FROM Cliente c WHERE c.email = :email", Long.class)
                           .setParameter("email", email)
                           .getSingleResult();
            return count > 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando email", e);
        }
    }

    // CORRECCIÓN: Método para obtener cliente con todos sus vehículos y detalles
    public Cliente obtenerClienteCompleto(int idCliente) {
        try {
            return em.createQuery("SELECT c FROM Cliente c " +
                                 "LEFT JOIN FETCH c.vehiculoList v " +
                                 "LEFT JOIN FETCH v.iDMarca " +
                                 "LEFT JOIN FETCH v.iDModelo " +
                                 "WHERE c.iDCliente = :id", Cliente.class)
                     .setParameter("id", idCliente)
                     .getSingleResult();
        } catch (Exception e) {
            return null;
        }
    }

    // CORRECCIÓN: Método para contar vehículos por cliente
    public int contarVehiculosPorCliente(int idCliente) {
        try {
            Long count = em.createQuery("SELECT COUNT(v) FROM Vehiculo v WHERE v.iDCliente.iDCliente = :idCliente", Long.class)
                           .setParameter("idCliente", idCliente)
                           .getSingleResult();
            return count != null ? count.intValue() : 0;
        } catch (Exception e) {
            throw new RuntimeException("Error contando vehículos del cliente", e);
        }
    }
}