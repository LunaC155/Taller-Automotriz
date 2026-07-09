package com.upec.dao;

import com.upec.model.OrdenServicio;
import com.upec.model.EstadoTrabajo;
import com.upec.model.Vehiculo;
import com.upec.model.Cliente;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import jakarta.transaction.Transactional;
import java.util.Date;
import java.util.List;

@Stateless
public class CitaDAO {

    @PersistenceContext(unitName = "taller_automotrizPU")
    private EntityManager em;

    public List<OrdenServicio> listarCitasProgramadas() {
        try {
            return em.createQuery(
                "SELECT o FROM OrdenServicio o " +
                "WHERE o.iDEstadoTrabajo.nombreEstado = 'CITA PROGRAMADA' " +
                "ORDER BY o.fechaEntrada ASC", 
                OrdenServicio.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando citas programadas", e);
        }
    }

    public List<OrdenServicio> listarCitasPorFecha(Date fecha) {
        try {
            return em.createQuery(
                "SELECT o FROM OrdenServicio o " +
                "WHERE FUNCTION('DATE', o.fechaEntrada) = FUNCTION('DATE', :fecha) " +
                "AND o.iDEstadoTrabajo.nombreEstado = 'CITA PROGRAMADA' " +
                "ORDER BY o.fechaEntrada ASC", 
                OrdenServicio.class)
                .setParameter("fecha", fecha)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando citas por fecha", e);
        }
    }

    @Transactional
    public boolean crearCita(OrdenServicio ordenCita) {
        try {
            // Buscar el estado "CITA PROGRAMADA"
            EstadoTrabajo estadoCita = em.createQuery(
                "SELECT e FROM EstadoTrabajo e WHERE e.nombreEstado = 'CITA PROGRAMADA'", 
                EstadoTrabajo.class)
                .getSingleResult();
            
            ordenCita.setIDEstadoTrabajo(estadoCita);
            em.persist(ordenCita);
            return true;
        } catch (Exception e) {
            throw new RuntimeException("Error creando cita", e);
        }
    }

    @Transactional
    public boolean actualizarCita(OrdenServicio ordenCita) {
        try {
            em.merge(ordenCita);
            return true;
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando cita", e);
        }
    }

    @Transactional
    public boolean cancelarCita(int idOrden) {
        try {
            OrdenServicio orden = em.find(OrdenServicio.class, idOrden);
            if (orden != null) {
                // Buscar el estado "CANCELADA"
                EstadoTrabajo estadoCancelada = em.createQuery(
                    "SELECT e FROM EstadoTrabajo e WHERE e.nombreEstado = 'CANCELADA'", 
                    EstadoTrabajo.class)
                    .getSingleResult();
                
                orden.setIDEstadoTrabajo(estadoCancelada);
                em.merge(orden);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error cancelando cita", e);
        }
    }

    public List<OrdenServicio> listarCitasPorCliente(int idCliente) {
        try {
            return em.createQuery(
                "SELECT o FROM OrdenServicio o " +
                "JOIN o.iDVehiculo v " +
                "WHERE v.iDCliente.iDCliente = :idCliente " +
                "AND o.iDEstadoTrabajo.nombreEstado = 'CITA PROGRAMADA' " +
                "ORDER BY o.fechaEntrada DESC", 
                OrdenServicio.class)
                .setParameter("idCliente", idCliente)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando citas por cliente", e);
        }
    }

    public boolean verificarDisponibilidadCita(Date fecha, String hora) {
        try {
            Long count = em.createQuery(
                "SELECT COUNT(o) FROM OrdenServicio o " +
                "WHERE FUNCTION('DATE', o.fechaEntrada) = FUNCTION('DATE', :fecha) " +
                "AND FUNCTION('HOUR', o.fechaEntrada) = :hora " +
                "AND o.iDEstadoTrabajo.nombreEstado = 'CITA PROGRAMADA'", 
                Long.class)
                .setParameter("fecha", fecha)
                .setParameter("hora", Integer.parseInt(hora))
                .getSingleResult();
            
            return count == 0;
        } catch (Exception e) {
            return false;
        }
    }

    public List<OrdenServicio> listarCitasProximas() {
        try {
            Date hoy = new Date();
            return em.createQuery(
                "SELECT o FROM OrdenServicio o " +
                "WHERE o.fechaEntrada >= :hoy " +
                "AND o.iDEstadoTrabajo.nombreEstado = 'CITA PROGRAMADA' " +
                "ORDER BY o.fechaEntrada ASC", 
                OrdenServicio.class)
                .setParameter("hoy", hoy)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando citas próximas", e);
        }
    }

    public int contarCitasHoy() {
        try {
            Date hoy = new Date();
            Long count = em.createQuery(
                "SELECT COUNT(o) FROM OrdenServicio o " +
                "WHERE FUNCTION('DATE', o.fechaEntrada) = FUNCTION('DATE', :hoy) " +
                "AND o.iDEstadoTrabajo.nombreEstado = 'CITA PROGRAMADA'", 
                Long.class)
                .setParameter("hoy", hoy)
                .getSingleResult();
            return count != null ? count.intValue() : 0;
        } catch (Exception e) {
            throw new RuntimeException("Error contando citas de hoy", e);
        }
    }

    public List<OrdenServicio> listarCitasProximasCliente(int idCliente) {
        try {
            Date hoy = new Date();
            return em.createQuery(
                "SELECT o FROM OrdenServicio o " +
                "JOIN o.iDVehiculo v " +
                "WHERE v.iDCliente.iDCliente = :idCliente " +
                "AND o.fechaEntrada >= :hoy " +
                "AND o.iDEstadoTrabajo.nombreEstado = 'CITA PROGRAMADA' " +
                "ORDER BY o.fechaEntrada ASC", 
                OrdenServicio.class)
                .setParameter("idCliente", idCliente)
                .setParameter("hoy", hoy)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando citas próximas del cliente", e);
        }
    }

    public List<OrdenServicio> listarCitasPasadasCliente(int idCliente) {
        try {
            Date hoy = new Date();
            return em.createQuery(
                "SELECT o FROM OrdenServicio o " +
                "JOIN o.iDVehiculo v " +
                "WHERE v.iDCliente.iDCliente = :idCliente " +
                "AND o.fechaEntrada < :hoy " +
                "AND o.iDEstadoTrabajo.nombreEstado = 'CITA PROGRAMADA' " +
                "ORDER BY o.fechaEntrada DESC", 
                OrdenServicio.class)
                .setParameter("idCliente", idCliente)
                .setParameter("hoy", hoy)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando citas pasadas del cliente", e);
        }
    }

    @Transactional
    public boolean reprogramarCita(int idOrden, Date nuevaFecha) {
        try {
            OrdenServicio orden = em.find(OrdenServicio.class, idOrden);
            if (orden != null && "CITA PROGRAMADA".equals(orden.getIDEstadoTrabajo().getNombreEstado())) {
                orden.setFechaEntrada(nuevaFecha);
                em.merge(orden);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error reprogramando cita", e);
        }
    }

    public List<Object[]> obtenerEstadisticasCitas() {
        try {
            return em.createQuery(
                "SELECT " +
                "COUNT(o) as totalCitas, " +
                "SUM(CASE WHEN o.fechaEntrada > CURRENT_TIMESTAMP THEN 1 ELSE 0 END) as citasFuturas, " +
                "SUM(CASE WHEN FUNCTION('DATE', o.fechaEntrada) = FUNCTION('DATE', CURRENT_TIMESTAMP) THEN 1 ELSE 0 END) as citasHoy, " +
                "SUM(CASE WHEN o.fechaEntrada < CURRENT_TIMESTAMP THEN 1 ELSE 0 END) as citasPasadas " +
                "FROM OrdenServicio o " +
                "WHERE o.iDEstadoTrabajo.nombreEstado = 'CITA PROGRAMADA'", 
                Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estadísticas de citas", e);
        }
    }

    public List<OrdenServicio> listarCitasConDetallesCompletos() {
        try {
            TypedQuery<OrdenServicio> query = em.createQuery(
                "SELECT o FROM OrdenServicio o " +
                "LEFT JOIN FETCH o.iDVehiculo v " +
                "LEFT JOIN FETCH v.iDCliente c " +
                "LEFT JOIN FETCH v.iDMarca " +
                "LEFT JOIN FETCH v.iDModelo " +
                "WHERE o.iDEstadoTrabajo.nombreEstado = 'CITA PROGRAMADA' " +
                "ORDER BY o.fechaEntrada ASC", 
                OrdenServicio.class);
            
            return query.getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando citas con detalles completos", e);
        }
    }

    public OrdenServicio obtenerCitaCompleta(int idOrden) {
        try {
            List<OrdenServicio> citas = em.createQuery(
                "SELECT o FROM OrdenServicio o " +
                "LEFT JOIN FETCH o.iDVehiculo v " +
                "LEFT JOIN FETCH v.iDCliente c " +
                "LEFT JOIN FETCH v.iDMarca " +
                "LEFT JOIN FETCH v.iDModelo " +
                "LEFT JOIN FETCH o.iDEmpleadoRecepcion " +
                "WHERE o.iDOrdenServicio = :id " +
                "AND o.iDEstadoTrabajo.nombreEstado = 'CITA PROGRAMADA'", 
                OrdenServicio.class)
                .setParameter("id", idOrden)
                .getResultList();
            return citas.isEmpty() ? null : citas.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo cita completa", e);
        }
    }

    public boolean existeCitaParaVehiculoEnFecha(int idVehiculo, Date fecha) {
        try {
            Long count = em.createQuery(
                "SELECT COUNT(o) FROM OrdenServicio o " +
                "WHERE o.iDVehiculo.iDVehiculo = :idVehiculo " +
                "AND FUNCTION('DATE', o.fechaEntrada) = FUNCTION('DATE', :fecha) " +
                "AND o.iDEstadoTrabajo.nombreEstado = 'CITA PROGRAMADA'", 
                Long.class)
                .setParameter("idVehiculo", idVehiculo)
                .setParameter("fecha", fecha)
                .getSingleResult();
            return count > 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando existencia de cita", e);
        }
    }

    public List<OrdenServicio> listarCitasPorRangoFechas(Date fechaInicio, Date fechaFin) {
        try {
            return em.createQuery(
                "SELECT o FROM OrdenServicio o " +
                "WHERE o.fechaEntrada BETWEEN :fechaInicio AND :fechaFin " +
                "AND o.iDEstadoTrabajo.nombreEstado = 'CITA PROGRAMADA' " +
                "ORDER BY o.fechaEntrada ASC", 
                OrdenServicio.class)
                .setParameter("fechaInicio", fechaInicio)
                .setParameter("fechaFin", fechaFin)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando citas por rango de fechas", e);
        }
    }
}