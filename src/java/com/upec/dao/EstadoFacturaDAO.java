package com.upec.dao;

import com.upec.model.EstadoFactura;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;
import java.util.List;

@Stateless
public class EstadoFacturaDAO {

    @PersistenceContext(unitName = "taller_automotrizPU")
    private EntityManager em;

    public List<EstadoFactura> listarEstadosFactura() {
        try {
            return em.createQuery("SELECT e FROM EstadoFactura e ORDER BY e.nombreEstado", EstadoFactura.class).getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando estados de factura", e);
        }
    }

    public EstadoFactura obtenerEstadoPorId(int id) {
        try {
            return em.find(EstadoFactura.class, id);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estado por ID", e);
        }
    }

    public EstadoFactura obtenerEstadoPorNombre(String nombre) {
        try {
            List<EstadoFactura> estados = em.createQuery(
                "SELECT e FROM EstadoFactura e WHERE e.nombreEstado = :nombre", 
                EstadoFactura.class)
                .setParameter("nombre", nombre)
                .getResultList();
            return estados.isEmpty() ? null : estados.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estado por nombre", e);
        }
    }

    // Métodos adicionales útiles (mantenidos para compatibilidad)
    
    public EstadoFactura findById(Integer id) {
        return obtenerEstadoPorId(id);
    }

    public List<EstadoFactura> findAll() {
        return listarEstadosFactura();
    }

    public EstadoFactura findByNombre(String nombreEstado) {
        return obtenerEstadoPorNombre(nombreEstado);
    }

    @Transactional
    public void create(EstadoFactura estadoFactura) {
        try {
            em.persist(estadoFactura);
        } catch (Exception e) {
            throw new RuntimeException("Error al crear estado de factura", e);
        }
    }

    @Transactional
    public void update(EstadoFactura estadoFactura) {
        try {
            em.merge(estadoFactura);
        } catch (Exception e) {
            throw new RuntimeException("Error al actualizar estado de factura", e);
        }
    }

    // Métodos adicionales útiles
    
    public List<EstadoFactura> listarEstadosActivos() {
        try {
            // Como no hay campo 'estado' en EstadoFactura, retornamos todos
            return em.createQuery("SELECT e FROM EstadoFactura e ORDER BY e.nombreEstado", EstadoFactura.class).getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando estados activos", e);
        }
    }

    public boolean existeEstadoConNombre(String nombre) {
        try {
            Long count = em.createQuery(
                "SELECT COUNT(e) FROM EstadoFactura e WHERE e.nombreEstado = :nombre", 
                Long.class)
                .setParameter("nombre", nombre)
                .getSingleResult();
            return count > 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando existencia de estado con nombre", e);
        }
    }

    public boolean puedeEliminarEstado(int idEstado) {
        try {
            // Verificar si hay facturas usando este estado
            Long count = em.createQuery(
                "SELECT COUNT(f) FROM Factura f WHERE f.iDEstadoFactura.iDEstadoFactura = :idEstado", 
                Long.class)
                .setParameter("idEstado", idEstado)
                .getSingleResult();
            
            // Verificar si es un estado del sistema (no se pueden eliminar)
            EstadoFactura estado = em.find(EstadoFactura.class, idEstado);
            boolean esEstadoSistema = estado != null && 
                                    (estado.getNombreEstado().equals("PENDIENTE") || 
                                     estado.getNombreEstado().equals("PAGADA") ||
                                     estado.getNombreEstado().equals("CANCELADA"));
            
            return count == 0 && !esEstadoSistema;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando si se puede eliminar estado", e);
        }
    }

    public List<EstadoFactura> buscarEstadosPorDescripcion(String descripcion) {
        try {
            return em.createQuery(
                "SELECT e FROM EstadoFactura e WHERE e.descripcion LIKE :descripcion ORDER BY e.nombreEstado", 
                EstadoFactura.class)
                .setParameter("descripcion", "%" + descripcion + "%")
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando estados por descripción", e);
        }
    }

    public Long contarTotalEstados() {
        try {
            return em.createQuery("SELECT COUNT(e) FROM EstadoFactura e", Long.class)
                     .getSingleResult();
        } catch (Exception e) {
            throw new RuntimeException("Error contando total de estados", e);
        }
    }

    public List<Object[]> contarFacturasPorEstado() {
        try {
            return em.createQuery(
                "SELECT e.nombreEstado, COUNT(f) FROM EstadoFactura e LEFT JOIN e.facturaList f GROUP BY e.nombreEstado ORDER BY COUNT(f) DESC", 
                Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error contando facturas por estado", e);
        }
    }

    // CORRECCIÓN: Métodos adicionales mejorados
    
    public List<EstadoFactura> obtenerEstadosParaFacturacion() {
        try {
            return em.createQuery(
                "SELECT e FROM EstadoFactura e " +
                "WHERE e.nombreEstado IN ('PENDIENTE', 'PAGADA', 'CANCELADA', 'ANULADA') " +
                "ORDER BY e.nombreEstado", 
                EstadoFactura.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estados para facturación", e);
        }
    }

    public EstadoFactura obtenerEstadoPendiente() {
        try {
            List<EstadoFactura> estados = em.createQuery(
                "SELECT e FROM EstadoFactura e WHERE e.nombreEstado = 'PENDIENTE'", 
                EstadoFactura.class)
                .getResultList();
            return estados.isEmpty() ? null : estados.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estado pendiente", e);
        }
    }

    public EstadoFactura obtenerEstadoPagada() {
        try {
            List<EstadoFactura> estados = em.createQuery(
                "SELECT e FROM EstadoFactura e WHERE e.nombreEstado = 'PAGADA'", 
                EstadoFactura.class)
                .getResultList();
            return estados.isEmpty() ? null : estados.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estado pagada", e);
        }
    }

    public EstadoFactura obtenerEstadoCancelada() {
        try {
            List<EstadoFactura> estados = em.createQuery(
                "SELECT e FROM EstadoFactura e WHERE e.nombreEstado = 'CANCELADA'", 
                EstadoFactura.class)
                .getResultList();
            return estados.isEmpty() ? null : estados.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estado cancelada", e);
        }
    }

    @Transactional
    public boolean cambiarEstadoFactura(int idEstadoActual, int idEstadoNuevo) {
        try {
            int updated = em.createQuery(
                "UPDATE Factura f SET f.iDEstadoFactura.iDEstadoFactura = :nuevoEstado " +
                "WHERE f.iDEstadoFactura.iDEstadoFactura = :estadoActual")
                .setParameter("nuevoEstado", idEstadoNuevo)
                .setParameter("estadoActual", idEstadoActual)
                .executeUpdate();
            
            return updated > 0;
        } catch (Exception e) {
            throw new RuntimeException("Error cambiando estado de facturas", e);
        }
    }

    public List<EstadoFactura> obtenerEstadosMasUtilizados(int limite) {
        try {
            return em.createQuery(
                "SELECT e FROM EstadoFactura e " +
                "LEFT JOIN e.facturaList f " +
                "GROUP BY e " +
                "ORDER BY COUNT(f) DESC", 
                EstadoFactura.class)
                .setMaxResults(limite)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estados más utilizados", e);
        }
    }

    @Transactional
    public boolean eliminarEstado(int idEstado) {
        try {
            if (!puedeEliminarEstado(idEstado)) {
                return false;
            }
            
            EstadoFactura estado = em.find(EstadoFactura.class, idEstado);
            if (estado != null) {
                em.remove(estado);
                return true;
            }
            
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error eliminando estado de factura", e);
        }
    }

    public List<EstadoFactura> buscarEstadosPorPatron(String patron) {
        try {
            return em.createQuery(
                "SELECT e FROM EstadoFactura e " +
                "WHERE e.nombreEstado LIKE :patron OR e.descripcion LIKE :patron " +
                "ORDER BY e.nombreEstado", 
                EstadoFactura.class)
                .setParameter("patron", "%" + patron + "%")
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando estados por patrón", e);
        }
    }

    // CORRECCIÓN: Métodos adicionales para gestión de estados
    
    public List<EstadoFactura> obtenerEstadosSistema() {
        try {
            return em.createQuery(
                "SELECT e FROM EstadoFactura e " +
                "WHERE e.nombreEstado IN ('PENDIENTE', 'PAGADA', 'CANCELADA', 'ANULADA', 'EN PROCESO') " +
                "ORDER BY e.nombreEstado", 
                EstadoFactura.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estados del sistema", e);
        }
    }

    public List<EstadoFactura> obtenerEstadosPersonalizados() {
        try {
            return em.createQuery(
                "SELECT e FROM EstadoFactura e " +
                "WHERE e.nombreEstado NOT IN ('PENDIENTE', 'PAGADA', 'CANCELADA', 'ANULADA', 'EN PROCESO') " +
                "ORDER BY e.nombreEstado", 
                EstadoFactura.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estados personalizados", e);
        }
    }

    public boolean esEstadoSistema(int idEstado) {
        try {
            EstadoFactura estado = em.find(EstadoFactura.class, idEstado);
            return estado != null && 
                   (estado.getNombreEstado().equals("PENDIENTE") || 
                    estado.getNombreEstado().equals("PAGADA") ||
                    estado.getNombreEstado().equals("CANCELADA") ||
                    estado.getNombreEstado().equals("ANULADA") ||
                    estado.getNombreEstado().equals("EN PROCESO"));
        } catch (Exception e) {
            throw new RuntimeException("Error verificando si es estado del sistema", e);
        }
    }

    public List<Object[]> obtenerEstadisticasUsoEstados() {
        try {
            return em.createQuery(
                "SELECT e.nombreEstado, " +
                "COUNT(f) as totalFacturas, " +
                "(COUNT(f) * 100.0 / (SELECT COUNT(*) FROM Factura)) as porcentaje " +
                "FROM EstadoFactura e " +
                "LEFT JOIN e.facturaList f " +
                "GROUP BY e.nombreEstado " +
                "ORDER BY COUNT(f) DESC", 
                Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estadísticas de uso de estados", e);
        }
    }

    public EstadoFactura obtenerEstadoPorDefecto() {
        try {
            List<EstadoFactura> estados = em.createQuery(
                "SELECT e FROM EstadoFactura e WHERE e.nombreEstado = 'PENDIENTE'", 
                EstadoFactura.class)
                .getResultList();
            return estados.isEmpty() ? null : estados.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estado por defecto", e);
        }
    }

    @Transactional
    public EstadoFactura crearEstadoPersonalizado(String nombre, String descripcion) {
        try {
            // Verificar si ya existe un estado con ese nombre
            if (existeEstadoConNombre(nombre)) {
                throw new RuntimeException("Ya existe un estado con el nombre: " + nombre);
            }

            EstadoFactura nuevoEstado = new EstadoFactura();
            nuevoEstado.setNombreEstado(nombre);
            nuevoEstado.setDescripcion(descripcion);
            
            em.persist(nuevoEstado);
            return nuevoEstado;
        } catch (Exception e) {
            throw new RuntimeException("Error creando estado personalizado", e);
        }
    }

    public List<EstadoFactura> obtenerEstadosParaFiltro() {
        try {
            return em.createQuery(
                "SELECT e FROM EstadoFactura e " +
                "ORDER BY CASE " +
                "WHEN e.nombreEstado = 'PENDIENTE' THEN 1 " +
                "WHEN e.nombreEstado = 'EN PROCESO' THEN 2 " +
                "WHEN e.nombreEstado = 'PAGADA' THEN 3 " +
                "WHEN e.nombreEstado = 'CANCELADA' THEN 4 " +
                "WHEN e.nombreEstado = 'ANULADA' THEN 5 " +
                "ELSE 6 END, e.nombreEstado", 
                EstadoFactura.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estados para filtro", e);
        }
    }
}