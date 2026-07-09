package com.upec.dao;

import com.upec.model.Factura;
import com.upec.model.OrdenServicio;
import com.upec.model.EstadoFactura;
import com.upec.model.DetalleFactura;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Stateless
public class FacturaDAO {

    @PersistenceContext(unitName = "taller_automotrizPU")
    private EntityManager em;

    // CRUD Básico (Recepcionista)
    public List<Factura> listarFacturas() {
        try {
            return em.createQuery("SELECT f FROM Factura f ORDER BY f.fechaEmision DESC", Factura.class).getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando facturas", e);
        }
    }

    public Factura obtenerFacturaPorId(int id) {
        try {
            return em.find(Factura.class, id);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo factura por ID", e);
        }
    }

    @Transactional
    public boolean crearFactura(Factura factura) {
        try {
            em.persist(factura);
            return true;
        } catch (Exception e) {
            throw new RuntimeException("Error creando factura", e);
        }
    }

    @Transactional
    public boolean actualizarFactura(Factura factura) {
        try {
            em.merge(factura);
            return true;
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando factura", e);
        }
    }

    // Para Recepcionista
    public List<Factura> listarFacturasPendientes() {
        try {
            return em.createQuery(
                "SELECT f FROM Factura f WHERE f.iDEstadoFactura.nombreEstado = 'PENDIENTE' ORDER BY f.fechaEmision DESC", 
                Factura.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando facturas pendientes", e);
        }
    }

    public List<Factura> listarFacturasPorFecha(Date fecha) {
        try {
            return em.createQuery(
                "SELECT f FROM Factura f WHERE FUNCTION('DATE', f.fechaEmision) = FUNCTION('DATE', :fecha) ORDER BY f.fechaEmision DESC", 
                Factura.class)
                .setParameter("fecha", fecha)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando facturas por fecha", e);
        }
    }

    @Transactional
    public boolean cambiarEstadoFactura(int idFactura, int idEstado) {
        try {
            Factura factura = em.find(Factura.class, idFactura);
            EstadoFactura estado = em.find(EstadoFactura.class, idEstado);
            
            if (factura != null && estado != null) {
                factura.setIDEstadoFactura(estado);
                em.merge(factura);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error cambiando estado de factura", e);
        }
    }

    // Para Cliente
    public List<Factura> listarFacturasPorCliente(int idCliente) {
        try {
            return em.createQuery(
                "SELECT f FROM Factura f " +
                "JOIN f.iDOrdenServicio o " +
                "JOIN o.iDVehiculo v " +
                "WHERE v.iDCliente.iDCliente = :idCliente " +
                "ORDER BY f.fechaEmision DESC", 
                Factura.class)
                .setParameter("idCliente", idCliente)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando facturas por cliente", e);
        }
    }

    public Factura obtenerFacturaCompleta(int idFactura) {
        try {
            List<Factura> facturas = em.createQuery(
                "SELECT f FROM Factura f " +
                "LEFT JOIN FETCH f.iDOrdenServicio o " +
                "LEFT JOIN FETCH o.iDVehiculo v " +
                "LEFT JOIN FETCH v.iDCliente " +
                "LEFT JOIN FETCH f.iDEstadoFactura " +
                "LEFT JOIN FETCH f.detalleFacturaList d " +
                "LEFT JOIN FETCH d.iDServicio " +
                "LEFT JOIN FETCH d.iDRepuesto " +
                "WHERE f.iDFactura = :id", 
                Factura.class)
                .setParameter("id", idFactura)
                .getResultList();
            return facturas.isEmpty() ? null : facturas.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo factura completa", e);
        }
    }

    // Para Reportes (Admin)
    public List<Factura> listarFacturasPorRangoFechas(Date inicio, Date fin) {
        try {
            return em.createQuery(
                "SELECT f FROM Factura f WHERE f.fechaEmision BETWEEN :inicio AND :fin ORDER BY f.fechaEmision DESC", 
                Factura.class)
                .setParameter("inicio", inicio)
                .setParameter("fin", fin)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando facturas por rango de fechas", e);
        }
    }

    public BigDecimal calcularTotalFacturadoPeriodo(Date inicio, Date fin) {
        try {
            BigDecimal result = em.createQuery(
                "SELECT SUM(f.total) FROM Factura f WHERE f.fechaEmision BETWEEN :inicio AND :fin", 
                BigDecimal.class)
                .setParameter("inicio", inicio)
                .setParameter("fin", fin)
                .getSingleResult();
            return result != null ? result : BigDecimal.ZERO;
        } catch (Exception e) {
            throw new RuntimeException("Error calculando total facturado en período", e);
        }
    }

    public List<Object[]> obtenerEstadisticasFacturacion() {
        try {
            return em.createQuery(
                "SELECT " +
                "COUNT(f) as totalFacturas, " +
                "SUM(f.total) as totalFacturado, " +
                "AVG(f.total) as promedioFactura, " +
                "SUM(CASE WHEN f.iDEstadoFactura.nombreEstado = 'PAGADA' THEN f.total ELSE 0 END) as totalPagado, " +
                "SUM(CASE WHEN f.iDEstadoFactura.nombreEstado = 'PENDIENTE' THEN f.total ELSE 0 END) as totalPendiente " +
                "FROM Factura f", 
                Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estadísticas de facturación", e);
        }
    }

    // Utilidades
    public String generarNumeroFactura() {
        try {
            List<String> ultimosNumeros = em.createQuery(
                "SELECT f.numeroFactura FROM Factura f ORDER BY f.iDFactura DESC", 
                String.class)
                .setMaxResults(1)
                .getResultList();

            if (!ultimosNumeros.isEmpty()) {
                String ultimoNumero = ultimosNumeros.get(0);
                try {
                    String[] partes = ultimoNumero.split("-");
                    int numero = Integer.parseInt(partes[partes.length - 1]);
                    return "FACT-" + String.format("%06d", numero + 1);
                } catch (NumberFormatException e) {
                    return "FACT-000001";
                }
            } else {
                return "FACT-000001";
            }
        } catch (Exception e) {
            return "FACT-000001";
        }
    }

    public Factura obtenerFacturaPorOrden(int idOrden) {
        try {
            List<Factura> facturas = em.createQuery(
                "SELECT f FROM Factura f WHERE f.iDOrdenServicio.iDOrdenServicio = :idOrden", 
                Factura.class)
                .setParameter("idOrden", idOrden)
                .getResultList();
            return facturas.isEmpty() ? null : facturas.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo factura por orden", e);
        }
    }

    // Métodos adicionales útiles (mantenidos para compatibilidad)
    
    @Transactional
    public void create(Factura factura) {
        try {
            em.persist(factura);
        } catch (Exception e) {
            throw new RuntimeException("Error al crear factura", e);
        }
    }

    @Transactional
    public void saveOrUpdate(Factura factura) {
        try {
            if (factura.getIDFactura() == null) {
                em.persist(factura);
            } else {
                em.merge(factura);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error guardando factura", e);
        }
    }

    public Factura findById(Integer id) {
        return obtenerFacturaPorId(id);
    }

    public Factura findByIdWithDetails(Integer id) {
        return obtenerFacturaCompleta(id);
    }

    public List<Factura> findAll() {
        try {
            return em.createQuery("SELECT f FROM Factura f ORDER BY f.fechaEmision DESC", Factura.class).getResultList();
        } catch (Exception e) {
            System.out.println("Error en findAll: " + e.getMessage());
            return new ArrayList<>();
        }
    }

    public List<Factura> findAllWithDetails() {
        try {
            return em.createQuery(
                "SELECT f FROM Factura f " +
                "LEFT JOIN FETCH f.iDOrdenServicio " +
                "LEFT JOIN FETCH f.iDEstadoFactura " +
                "ORDER BY f.fechaEmision DESC", 
                Factura.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando todas las facturas con detalles", e);
        }
    }

    public Factura findByNumeroFactura(String numeroFactura) {
        try {
            List<Factura> facturas = em.createQuery(
                "SELECT f FROM Factura f WHERE f.numeroFactura = :numeroFactura", 
                Factura.class)
                .setParameter("numeroFactura", numeroFactura)
                .getResultList();
            return facturas.isEmpty() ? null : facturas.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error buscando factura por número", e);
        }
    }

    public List<Factura> findByOrdenServicio(Integer idOrdenServicio) {
        try {
            return em.createQuery(
                "SELECT f FROM Factura f WHERE f.iDOrdenServicio.iDOrdenServicio = :idOrdenServicio", 
                Factura.class)
                .setParameter("idOrdenServicio", idOrdenServicio)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando facturas por orden de servicio", e);
        }
    }

    public List<Factura> findByEstadoFactura(Integer idEstado) {
        try {
            return em.createQuery(
                "SELECT f FROM Factura f WHERE f.iDEstadoFactura.iDEstadoFactura = :idEstado", 
                Factura.class)
                .setParameter("idEstado", idEstado)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando facturas por estado", e);
        }
    }

    public List<Factura> findByFechaEmisionBetween(Date fechaInicio, Date fechaFin) {
        return listarFacturasPorRangoFechas(fechaInicio, fechaFin);
    }

    public List<Factura> findByTotalBetween(BigDecimal min, BigDecimal max) {
        try {
            return em.createQuery(
                "SELECT f FROM Factura f WHERE f.total BETWEEN :min AND :max ORDER BY f.fechaEmision DESC", 
                Factura.class)
                .setParameter("min", min)
                .setParameter("max", max)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando facturas por rango de total", e);
        }
    }

    public List<Factura> findFacturasPendientesPago() {
        return listarFacturasPendientes();
    }

    public List<Factura> findFacturasPagadas() {
        try {
            return em.createQuery(
                "SELECT f FROM Factura f WHERE f.iDEstadoFactura.nombreEstado = 'PAGADA' ORDER BY f.fechaEmision DESC", 
                Factura.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando facturas pagadas", e);
        }
    }

    public boolean numeroFacturaExists(String numeroFactura) {
        try {
            Long count = em.createQuery(
                "SELECT COUNT(f) FROM Factura f WHERE f.numeroFactura = :numeroFactura", 
                Long.class)
                .setParameter("numeroFactura", numeroFactura)
                .getSingleResult();
            return count > 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando existencia de número de factura", e);
        }
    }

    @Transactional
    public void delete(Integer id) {
        try {
            Factura factura = em.find(Factura.class, id);
            if (factura != null) {
                em.remove(factura);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error eliminando factura", e);
        }
    }

    @Transactional
    public void updateEstadoFactura(Integer id, EstadoFactura estadoFactura) {
        try {
            Factura factura = em.find(Factura.class, id);
            if (factura != null) {
                factura.setIDEstadoFactura(estadoFactura);
                em.merge(factura);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando estado de la factura", e);
        }
    }

    @Transactional
    public void updateTotales(Integer id, BigDecimal subtotal, BigDecimal iva, BigDecimal total) {
        try {
            Factura factura = em.find(Factura.class, id);
            if (factura != null) {
                factura.setSubtotal(subtotal);
                factura.setIva(iva);
                factura.setTotal(total);
                em.merge(factura);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando totales de la factura", e);
        }
    }

    public Long countFacturasPorEstado(Integer idEstado) {
        try {
            return em.createQuery(
                "SELECT COUNT(f) FROM Factura f WHERE f.iDEstadoFactura.iDEstadoFactura = :idEstado", 
                Long.class)
                .setParameter("idEstado", idEstado)
                .getSingleResult();
        } catch (Exception e) {
            throw new RuntimeException("Error contando facturas por estado", e);
        }
    }

    public BigDecimal getTotalFacturadoEnPeriodo(Date fechaInicio, Date fechaFin) {
        return calcularTotalFacturadoPeriodo(fechaInicio, fechaFin);
    }

    public List<Object[]> getFacturasConDetallesCompletos() {
        try {
            return em.createQuery(
                "SELECT f, o, v, c, ef FROM Factura f " +
                "JOIN f.iDOrdenServicio o " +
                "JOIN o.iDVehiculo v " +
                "JOIN v.iDCliente c " +
                "JOIN f.iDEstadoFactura ef " +
                "ORDER BY f.fechaEmision DESC", 
                Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo facturas con detalles completos", e);
        }
    }

    public List<Factura> findByNumeroFacturaContaining(String texto) {
        try {
            return em.createQuery(
                "SELECT f FROM Factura f WHERE f.numeroFactura LIKE :texto ORDER BY f.fechaEmision DESC", 
                Factura.class)
                .setParameter("texto", "%" + texto + "%")
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando facturas por número que contiene texto", e);
        }
    }

    public boolean existeFacturaParaOrden(int idOrden) {
        try {
            Long count = em.createQuery(
                "SELECT COUNT(f) FROM Factura f WHERE f.iDOrdenServicio.iDOrdenServicio = :idOrden", 
                Long.class)
                .setParameter("idOrden", idOrden)
                .getSingleResult();
            return count > 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando existencia de factura para orden", e);
        }
    }

    public List<Factura> listarFacturasRecientes(int limite) {
        try {
            return em.createQuery(
                "SELECT f FROM Factura f ORDER BY f.fechaEmision DESC", 
                Factura.class)
                .setMaxResults(limite)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando facturas recientes", e);
        }
    }

    public BigDecimal calcularSaldoPendienteCliente(int idCliente) {
        try {
            BigDecimal result = em.createQuery(
                "SELECT SUM(f.total) FROM Factura f " +
                "JOIN f.iDOrdenServicio o " +
                "JOIN o.iDVehiculo v " +
                "WHERE v.iDCliente.iDCliente = :idCliente " +
                "AND f.iDEstadoFactura.nombreEstado = 'PENDIENTE'", 
                BigDecimal.class)
                .setParameter("idCliente", idCliente)
                .getSingleResult();
            return result != null ? result : BigDecimal.ZERO;
        } catch (Exception e) {
            throw new RuntimeException("Error calculando saldo pendiente del cliente", e);
        }
    }

    public List<Factura> listarFacturasConDetallesCompletos() {
        try {
            return em.createQuery(
                "SELECT f FROM Factura f " +
                "LEFT JOIN FETCH f.iDOrdenServicio o " +
                "LEFT JOIN FETCH o.iDVehiculo v " +
                "LEFT JOIN FETCH v.iDCliente c " +
                "LEFT JOIN FETCH f.iDEstadoFactura ef " +
                "LEFT JOIN FETCH f.detalleFacturaList d " +
                "ORDER BY f.fechaEmision DESC", 
                Factura.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando facturas con detalles completos", e);
        }
    }

    public List<Object[]> obtenerFacturacionMensual(int año) {
        try {
            return em.createQuery(
                "SELECT MONTH(f.fechaEmision), SUM(f.total) " +
                "FROM Factura f " +
                "WHERE YEAR(f.fechaEmision) = :año " +
                "AND f.iDEstadoFactura.nombreEstado = 'PAGADA' " +
                "GROUP BY MONTH(f.fechaEmision) " +
                "ORDER BY MONTH(f.fechaEmision)", 
                Object[].class)
                .setParameter("año", año)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo facturación mensual", e);
        }
    }

    public int contarFacturasHoy() {
        try {
            Date hoy = new Date();
            Long count = em.createQuery(
                "SELECT COUNT(f) FROM Factura f WHERE FUNCTION('DATE', f.fechaEmision) = FUNCTION('DATE', :hoy)", 
                Long.class)
                .setParameter("hoy", hoy)
                .getSingleResult();
            return count != null ? count.intValue() : 0;
        } catch (Exception e) {
            throw new RuntimeException("Error contando facturas de hoy", e);
        }
    }

    @Transactional
    public boolean marcarFacturaComoPagada(int idFactura) {
        try {
            Factura factura = em.find(Factura.class, idFactura);
            if (factura != null) {
                EstadoFactura estadoPagada = em.createQuery(
                    "SELECT e FROM EstadoFactura e WHERE e.nombreEstado = 'PAGADA'", 
                    EstadoFactura.class)
                    .getSingleResult();
                
                factura.setIDEstadoFactura(estadoPagada);
                em.merge(factura);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error marcando factura como pagada", e);
        }
    }

    public List<Factura> buscarFacturasPorCriterio(String criterio) {
        try {
            return em.createQuery(
                "SELECT f FROM Factura f " +
                "LEFT JOIN f.iDOrdenServicio o " +
                "LEFT JOIN o.iDVehiculo v " +
                "LEFT JOIN v.iDCliente c " +
                "WHERE f.numeroFactura LIKE :criterio " +
                "OR c.nombre LIKE :criterio " +
                "OR c.apellido LIKE :criterio " +
                "OR v.placa LIKE :criterio " +
                "ORDER BY f.fechaEmision DESC", 
                Factura.class)
                .setParameter("criterio", "%" + criterio + "%")
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando facturas por criterio", e);
        }
    }

    public BigDecimal calcularIVA(BigDecimal subtotal) {
        return subtotal.multiply(new BigDecimal("0.12"));
    }

    @Transactional
    public Factura generarFacturaDesdeOrden(int idOrden, BigDecimal subtotal) {
        try {
            if (existeFacturaParaOrden(idOrden)) {
                throw new RuntimeException("Ya existe una factura para esta orden de servicio");
            }

            OrdenServicio orden = em.find(OrdenServicio.class, idOrden);
            if (orden == null) {
                throw new RuntimeException("No se encontró la orden de servicio");
            }

            Factura factura = new Factura();
            factura.setIDOrdenServicio(orden);
            
            EstadoFactura estadoPendiente = em.createQuery(
                "SELECT e FROM EstadoFactura e WHERE e.nombreEstado = 'PENDIENTE'", 
                EstadoFactura.class)
                .getSingleResult();
            factura.setIDEstadoFactura(estadoPendiente);
            
            factura.setNumeroFactura(generarNumeroFactura());
            factura.setFechaEmision(new Date());
            factura.setSubtotal(subtotal);
            
            BigDecimal iva = calcularIVA(subtotal);
            factura.setIva(iva);
            factura.setTotal(subtotal.add(iva));
            
            em.persist(factura);
            return factura;
        } catch (Exception e) {
            throw new RuntimeException("Error generando factura desde orden", e);
        }
    }

    public List<Object[]> obtenerTopClientesFacturacion(int limite) {
        try {
            return em.createQuery(
                "SELECT c.nombre, c.apellido, SUM(f.total) as totalFacturado " +
                "FROM Factura f " +
                "JOIN f.iDOrdenServicio o " +
                "JOIN o.iDVehiculo v " +
                "JOIN v.iDCliente c " +
                "WHERE f.iDEstadoFactura.nombreEstado = 'PAGADA' " +
                "GROUP BY c.nombre, c.apellido " +
                "ORDER BY totalFacturado DESC", 
                Object[].class)
                .setMaxResults(limite)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo top clientes por facturación", e);
        }
    }
}