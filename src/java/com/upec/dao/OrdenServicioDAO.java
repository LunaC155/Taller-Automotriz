package com.upec.dao;

import com.upec.model.OrdenServicio;
import com.upec.model.Vehiculo;
import com.upec.model.Empleado;
import com.upec.model.EstadoTrabajo;
import com.upec.model.Cliente;
import com.upec.model.Diagnostico;
import com.upec.model.Factura;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;
import java.util.Date;
import java.util.List;

@Stateless
public class OrdenServicioDAO {

    @PersistenceContext(unitName = "taller_automotrizPU")
    private EntityManager em;

    // CRUD Básico
    public List<OrdenServicio> listarOrdenes() {
        try {
            return em.createQuery("SELECT o FROM OrdenServicio o", OrdenServicio.class).getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando órdenes", e);
        }
    }

    public OrdenServicio obtenerOrdenPorId(int id) {
        try {
            return em.find(OrdenServicio.class, id);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo orden por ID", e);
        }
    }

    @Transactional
    public boolean crearOrden(OrdenServicio orden) {
        try {
            em.persist(orden);
            return true;
        } catch (Exception e) {
            throw new RuntimeException("Error creando orden", e);
        }
    }

    @Transactional
    public boolean actualizarOrden(OrdenServicio orden) {
        try {
            em.merge(orden);
            return true;
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando orden", e);
        }
    }

    @Transactional
    public boolean eliminarOrden(int id) {
        try {
            OrdenServicio ordenServicio = em.find(OrdenServicio.class, id);
            if (ordenServicio != null) {
                // Verificar si hay facturas o diagnósticos asociados
                if (!puedeEliminarOrden(id)) {
                    return false;
                }
                em.remove(ordenServicio);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error eliminando orden", e);
        }
    }

    // Para Recepcionista
    public List<OrdenServicio> listarOrdenesPendientes() {
        try {
            return em.createQuery(
                    "SELECT o FROM OrdenServicio o WHERE o.fechaRealSalida IS NULL AND o.fechaEstimadaSalida >= CURRENT_DATE",
                    OrdenServicio.class)
                    .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando órdenes pendientes", e);
        }
    }

    public List<OrdenServicio> listarOrdenesPorFecha(Date fecha) {
        try {
            return em.createQuery("SELECT o FROM OrdenServicio o WHERE FUNCTION('DATE', o.fechaEntrada) = FUNCTION('DATE', :fecha)", OrdenServicio.class)
                    .setParameter("fecha", fecha)
                    .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando órdenes por fecha", e);
        }
    }

    @Transactional
    public boolean asignarVehiculoAOrden(int idOrden, int idVehiculo) {
        try {
            OrdenServicio orden = em.find(OrdenServicio.class, idOrden);
            Vehiculo vehiculo = em.find(Vehiculo.class, idVehiculo);
            
            if (orden != null && vehiculo != null) {
                orden.setIDVehiculo(vehiculo);
                em.merge(orden);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error asignando vehículo a orden", e);
        }
    }

    // Para Mecánico
    public List<OrdenServicio> listarOrdenesPorMecanico(int idMecanico) {
        try {
            // Asumiendo que los diagnósticos están relacionados con los mecánicos
            return em.createQuery(
                "SELECT DISTINCT o FROM OrdenServicio o JOIN o.diagnosticoList d WHERE d.iDEmpleadoMecanico.iDEmpleado = :idMecanico", 
                OrdenServicio.class)
                .setParameter("idMecanico", idMecanico)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando órdenes por mecánico", e);
        }
    }

    public List<OrdenServicio> listarOrdenesPorEstado(int idEstado) {
        try {
            return em.createQuery("SELECT o FROM OrdenServicio o WHERE o.iDEstadoTrabajo.iDEstadoTrabajo = :idEstado", OrdenServicio.class)
                    .setParameter("idEstado", idEstado)
                    .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando órdenes por estado", e);
        }
    }

    @Transactional
    public boolean actualizarEstadoOrden(int idOrden, int idEstado) {
        try {
            OrdenServicio orden = em.find(OrdenServicio.class, idOrden);
            EstadoTrabajo estado = em.find(EstadoTrabajo.class, idEstado);
            
            if (orden != null && estado != null) {
                orden.setIDEstadoTrabajo(estado);
                em.merge(orden);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando estado de orden", e);
        }
    }

    // Para Cliente
    public List<OrdenServicio> listarOrdenesPorCliente(int idCliente) {
        try {
            return em.createQuery(
                "SELECT o FROM OrdenServicio o WHERE o.iDVehiculo.iDCliente.iDCliente = :idCliente", 
                OrdenServicio.class)
                .setParameter("idCliente", idCliente)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando órdenes por cliente", e);
        }
    }

    public List<OrdenServicio> listarOrdenesPorVehiculo(int idVehiculo) {
        try {
            return em.createQuery("SELECT o FROM OrdenServicio o WHERE o.iDVehiculo.iDVehiculo = :idVehiculo", OrdenServicio.class)
                    .setParameter("idVehiculo", idVehiculo)
                    .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando órdenes por vehículo", e);
        }
    }

    // Para Dashboard y Reportes
    public int contarOrdenesPorEstado(int idEstado) {
        try {
            Long count = em.createQuery("SELECT COUNT(o) FROM OrdenServicio o WHERE o.iDEstadoTrabajo.iDEstadoTrabajo = :idEstado", Long.class)
                    .setParameter("idEstado", idEstado)
                    .getSingleResult();
            return count != null ? count.intValue() : 0;
        } catch (Exception e) {
            throw new RuntimeException("Error contando órdenes por estado", e);
        }
    }

    public List<OrdenServicio> listarOrdenesPorRangoFechas(Date inicio, Date fin) {
        try {
            return em.createQuery("SELECT o FROM OrdenServicio o WHERE o.fechaEntrada BETWEEN :inicio AND :fin", OrdenServicio.class)
                    .setParameter("inicio", inicio)
                    .setParameter("fin", fin)
                    .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando órdenes por rango de fechas", e);
        }
    }

    public double calcularTiempoPromedioReparacion() {
        try {
            // Calcular el promedio de días entre fechaEntrada y fechaRealSalida para órdenes completadas
            Double promedio = em.createQuery(
                "SELECT AVG(FUNCTION('DATEDIFF', o.fechaRealSalida, o.fechaEntrada)) FROM OrdenServicio o WHERE o.fechaRealSalida IS NOT NULL", 
                Double.class)
                .getSingleResult();
            return promedio != null ? promedio : 0.0;
        } catch (Exception e) {
            throw new RuntimeException("Error calculando tiempo promedio de reparación", e);
        }
    }

    public List<Object[]> obtenerEstadisticasOrdenes() {
        try {
            return em.createQuery(
                "SELECT " +
                "COUNT(o) as totalOrdenes, " +
                "SUM(CASE WHEN o.fechaRealSalida IS NULL THEN 1 ELSE 0 END) as ordenesPendientes, " +
                "SUM(CASE WHEN o.fechaRealSalida IS NOT NULL THEN 1 ELSE 0 END) as ordenesCompletadas, " +
                "AVG(CASE WHEN o.fechaRealSalida IS NOT NULL THEN FUNCTION('DATEDIFF', o.fechaRealSalida, o.fechaEntrada) ELSE NULL END) as tiempoPromedio " +
                "FROM OrdenServicio o", Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estadísticas de órdenes", e);
        }
    }

    // Para Facturación
    public OrdenServicio obtenerOrdenCompleta(int idOrden) {
        try {
            List<OrdenServicio> ordenes = em.createQuery(
                "SELECT o FROM OrdenServicio o " +
                "LEFT JOIN FETCH o.iDVehiculo v " +
                "LEFT JOIN FETCH v.iDCliente " +
                "LEFT JOIN FETCH o.diagnosticoList " +
                "LEFT JOIN FETCH o.facturaList " +
                "WHERE o.iDOrdenServicio = :id", 
                OrdenServicio.class)
                .setParameter("id", idOrden)
                .getResultList();
            return ordenes.isEmpty() ? null : ordenes.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo orden completa", e);
        }
    }

    // Métodos adicionales útiles (mantenidos para compatibilidad)
    
    public OrdenServicio findByIdWithDetails(Integer id) {
        return obtenerOrdenCompleta(id);
    }

    public List<OrdenServicio> findAllWithDetails() {
        try {
            return em.createQuery(
                    "SELECT o FROM OrdenServicio o " +
                    "LEFT JOIN FETCH o.iDVehiculo " +
                    "LEFT JOIN FETCH o.iDEmpleadoRecepcion " +
                    "LEFT JOIN FETCH o.iDEstadoTrabajo",
                    OrdenServicio.class)
                    .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando todas las órdenes con detalles", e);
        }
    }

    public List<OrdenServicio> findOrdenesAtrasadas() {
        try {
            return em.createQuery(
                    "SELECT o FROM OrdenServicio o WHERE o.fechaRealSalida IS NULL AND o.fechaEstimadaSalida < CURRENT_DATE",
                    OrdenServicio.class)
                    .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando órdenes atrasadas", e);
        }
    }

    public List<OrdenServicio> findOrdenesCompletadas() {
        try {
            return em.createQuery("SELECT o FROM OrdenServicio o WHERE o.fechaRealSalida IS NOT NULL", OrdenServicio.class)
                    .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando órdenes completadas", e);
        }
    }

    public Long countOrdenesPendientes() {
        try {
            return em.createQuery("SELECT COUNT(o) FROM OrdenServicio o WHERE o.fechaRealSalida IS NULL", Long.class)
                    .getSingleResult();
        } catch (Exception e) {
            throw new RuntimeException("Error contando órdenes pendientes", e);
        }
    }

    public List<OrdenServicio> findByProblemaReportadoContaining(String texto) {
        try {
            return em.createQuery("SELECT o FROM OrdenServicio o WHERE o.problemaReportado LIKE :texto", OrdenServicio.class)
                    .setParameter("texto", "%" + texto + "%")
                    .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando órdenes por problema reportado", e);
        }
    }

    // CORRECCIÓN: Métodos adicionales mejorados
    
    public boolean puedeEliminarOrden(int idOrden) {
        try {
            // Verificar si hay facturas o diagnósticos asociados
            Long countFacturas = em.createQuery(
                "SELECT COUNT(f) FROM Factura f WHERE f.iDOrdenServicio.iDOrdenServicio = :idOrden", 
                Long.class)
                .setParameter("idOrden", idOrden)
                .getSingleResult();
            
            Long countDiagnosticos = em.createQuery(
                "SELECT COUNT(d) FROM Diagnostico d WHERE d.iDOrdenServicio.iDOrdenServicio = :idOrden", 
                Long.class)
                .setParameter("idOrden", idOrden)
                .getSingleResult();
            
            return countFacturas == 0 && countDiagnosticos == 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando si se puede eliminar orden", e);
        }
    }

    public List<OrdenServicio> listarOrdenesConDetallesCompletos() {
        try {
            return em.createQuery(
                "SELECT o FROM OrdenServicio o " +
                "LEFT JOIN FETCH o.iDVehiculo v " +
                "LEFT JOIN FETCH v.iDCliente c " +
                "LEFT JOIN FETCH v.iDMarca " +
                "LEFT JOIN FETCH v.iDModelo " +
                "LEFT JOIN FETCH o.iDEmpleadoRecepcion " +
                "LEFT JOIN FETCH o.iDEstadoTrabajo " +
                "ORDER BY o.fechaEntrada DESC", 
                OrdenServicio.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando órdenes con detalles completos", e);
        }
    }

    @Transactional
    public boolean marcarOrdenComoCompletada(int idOrden) {
        try {
            OrdenServicio orden = em.find(OrdenServicio.class, idOrden);
            if (orden != null) {
                orden.setFechaRealSalida(new Date());
                
                // Buscar estado "COMPLETADO"
                EstadoTrabajo estadoCompletado = em.createQuery(
                    "SELECT e FROM EstadoTrabajo e WHERE e.nombreEstado = 'COMPLETADO'", 
                    EstadoTrabajo.class)
                    .getSingleResult();
                
                orden.setIDEstadoTrabajo(estadoCompletado);
                em.merge(orden);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error marcando orden como completada", e);
        }
    }

    public List<OrdenServicio> buscarOrdenesPorCriterio(String criterio) {
        try {
            return em.createQuery(
                "SELECT o FROM OrdenServicio o " +
                "LEFT JOIN o.iDVehiculo v " +
                "LEFT JOIN v.iDCliente c " +
                "LEFT JOIN v.iDMarca m " +
                "LEFT JOIN v.iDModelo mod " +
                "WHERE o.problemaReportado LIKE :criterio " +
                "OR c.nombre LIKE :criterio " +
                "OR c.apellido LIKE :criterio " +
                "OR v.placa LIKE :criterio " +
                "OR m.nombreMarca LIKE :criterio " +
                "OR mod.nombreModelo LIKE :criterio " +
                "ORDER BY o.fechaEntrada DESC", 
                OrdenServicio.class)
                .setParameter("criterio", "%" + criterio + "%")
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando órdenes por criterio", e);
        }
    }

    public List<Object[]> obtenerOrdenesPorMecanicoYEstado(int idMecanico, int idEstado) {
        try {
            return em.createQuery(
                "SELECT o, d FROM OrdenServicio o " +
                "JOIN o.diagnosticoList d " +
                "WHERE d.iDEmpleadoMecanico.iDEmpleado = :idMecanico " +
                "AND o.iDEstadoTrabajo.iDEstadoTrabajo = :idEstado " +
                "ORDER BY o.fechaEntrada DESC", 
                Object[].class)
                .setParameter("idMecanico", idMecanico)
                .setParameter("idEstado", idEstado)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo órdenes por mecánico y estado", e);
        }
    }

    public int contarOrdenesHoy() {
        try {
            Date hoy = new Date();
            Long count = em.createQuery(
                "SELECT COUNT(o) FROM OrdenServicio o WHERE FUNCTION('DATE', o.fechaEntrada) = FUNCTION('DATE', :hoy)", 
                Long.class)
                .setParameter("hoy", hoy)
                .getSingleResult();
            return count != null ? count.intValue() : 0;
        } catch (Exception e) {
            throw new RuntimeException("Error contando órdenes de hoy", e);
        }
    }

    public List<Object[]> obtenerTopClientesOrdenes(int limite) {
        try {
            return em.createQuery(
                "SELECT c.nombre, c.apellido, COUNT(o) as totalOrdenes " +
                "FROM OrdenServicio o " +
                "JOIN o.iDVehiculo v " +
                "JOIN v.iDCliente c " +
                "GROUP BY c.nombre, c.apellido " +
                "ORDER BY totalOrdenes DESC", 
                Object[].class)
                .setMaxResults(limite)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo top clientes por órdenes", e);
        }
    }

    @Transactional
    public OrdenServicio crearOrdenDesdeVehiculo(int idVehiculo, int idEmpleadoRecepcion, String problemaReportado) {
        try {
            Vehiculo vehiculo = em.find(Vehiculo.class, idVehiculo);
            Empleado empleado = em.find(Empleado.class, idEmpleadoRecepcion);
            
            if (vehiculo == null || empleado == null) {
                throw new RuntimeException("Vehículo o empleado no encontrado");
            }

            // Buscar estado "PENDIENTE" por defecto
            EstadoTrabajo estadoPendiente = em.createQuery(
                "SELECT e FROM EstadoTrabajo e WHERE e.nombreEstado = 'PENDIENTE'", 
                EstadoTrabajo.class)
                .getSingleResult();

            OrdenServicio nuevaOrden = new OrdenServicio();
            nuevaOrden.setIDVehiculo(vehiculo);
            nuevaOrden.setIDEmpleadoRecepcion(empleado);
            nuevaOrden.setIDEstadoTrabajo(estadoPendiente);
            nuevaOrden.setProblemaReportado(problemaReportado);
            nuevaOrden.setFechaEntrada(new Date());
            
            // Establecer fecha estimada de salida (por ejemplo, 3 días después)
            java.util.Calendar calendar = java.util.Calendar.getInstance();
            calendar.add(java.util.Calendar.DAY_OF_MONTH, 3);
            nuevaOrden.setFechaEstimadaSalida(calendar.getTime());
            
            em.persist(nuevaOrden);
            return nuevaOrden;
        } catch (Exception e) {
            throw new RuntimeException("Error creando orden desde vehículo", e);
        }
    }
}