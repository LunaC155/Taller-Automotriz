package com.upec.dao;

import com.upec.model.Vehiculo;
import com.upec.model.Cliente;
import com.upec.model.Marca;
import com.upec.model.Modelo;
import com.upec.model.OrdenServicio;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;
import java.util.List;

@Stateless
public class VehiculoDAO {

    @PersistenceContext(unitName = "taller_automotrizPU")
    private EntityManager em;

    // CRUD Básico (Admin)
    public List<Vehiculo> listarVehiculos() {
        try {
            return em.createQuery("SELECT v FROM Vehiculo v", Vehiculo.class).getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando vehículos", e);
        }
    }

    public Vehiculo obtenerVehiculoPorId(int id) {
        try {
            return em.find(Vehiculo.class, id);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo vehículo por ID", e);
        }
    }

    @Transactional
    public boolean crearVehiculo(Vehiculo vehiculo) {
        try {
            em.persist(vehiculo);
            return true;
        } catch (Exception e) {
            throw new RuntimeException("Error creando vehículo", e);
        }
    }

    @Transactional
    public boolean actualizarVehiculo(Vehiculo vehiculo) {
        try {
            em.merge(vehiculo);
            return true;
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando vehículo", e);
        }
    }

    @Transactional
    public boolean eliminarVehiculo(int id) {
        try {
            Vehiculo vehiculo = em.find(Vehiculo.class, id);
            if (vehiculo != null) {
                // Verificar si hay órdenes de servicio asociadas
                Long count = em.createQuery(
                    "SELECT COUNT(o) FROM OrdenServicio o WHERE o.iDVehiculo.iDVehiculo = :idVehiculo", 
                    Long.class)
                    .setParameter("idVehiculo", id)
                    .getSingleResult();
                
                if (count > 0) {
                    return false;
                }
                em.remove(vehiculo);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error eliminando vehículo", e);
        }
    }

    // Para Admin
    public List<Vehiculo> buscarVehiculosPorPlaca(String placa) {
        try {
            return em.createQuery("SELECT v FROM Vehiculo v WHERE v.placa LIKE :placa", Vehiculo.class)
                     .setParameter("placa", "%" + placa + "%")
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando vehículos por placa", e);
        }
    }

    public List<Vehiculo> filtrarVehiculosPorMarca(int idMarca) {
        try {
            return em.createQuery("SELECT v FROM Vehiculo v WHERE v.iDMarca.iDMarca = :idMarca", Vehiculo.class)
                     .setParameter("idMarca", idMarca)
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error filtrando vehículos por marca", e);
        }
    }

    public List<Vehiculo> filtrarVehiculosPorModelo(int idModelo) {
        try {
            return em.createQuery("SELECT v FROM Vehiculo v WHERE v.iDModelo.iDModelo = :idModelo", Vehiculo.class)
                     .setParameter("idModelo", idModelo)
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error filtrando vehículos por modelo", e);
        }
    }

    // Para Cliente
    public List<Vehiculo> listarVehiculosPorCliente(int idCliente) {
        try {
            return em.createQuery("SELECT v FROM Vehiculo v WHERE v.iDCliente.iDCliente = :idCliente", Vehiculo.class)
                     .setParameter("idCliente", idCliente)
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando vehículos por cliente", e);
        }
    }

    public Vehiculo obtenerVehiculoConHistorial(int idVehiculo) {
        try {
            List<Vehiculo> vehiculos = em.createQuery(
                "SELECT v FROM Vehiculo v " +
                "LEFT JOIN FETCH v.ordenServicioList o " +
                "LEFT JOIN FETCH o.diagnosticoList " +
                "LEFT JOIN FETCH o.facturaList " +
                "WHERE v.iDVehiculo = :id", 
                Vehiculo.class)
                .setParameter("id", idVehiculo)
                .getResultList();
            return vehiculos.isEmpty() ? null : vehiculos.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo vehículo con historial", e);
        }
    }

    // Para Recepcionista
    public List<Vehiculo> listarVehiculosActivos() {
        try {
            return em.createQuery("SELECT v FROM Vehiculo v WHERE v.estado = true", Vehiculo.class)
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando vehículos activos", e);
        }
    }

    public boolean verificarDisponibilidadVehiculo(int idVehiculo) {
        try {
            // Un vehículo está disponible si no tiene órdenes de servicio activas (sin fecha de salida real)
            Long count = em.createQuery(
                "SELECT COUNT(o) FROM OrdenServicio o WHERE o.iDVehiculo.iDVehiculo = :idVehiculo AND o.fechaRealSalida IS NULL", 
                Long.class)
                .setParameter("idVehiculo", idVehiculo)
                .getSingleResult();
            return count == 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando disponibilidad del vehículo", e);
        }
    }

    // Para Reportes
    public int contarTotalVehiculos() {
        try {
            Long count = em.createQuery("SELECT COUNT(v) FROM Vehiculo v", Long.class)
                     .getSingleResult();
            return count != null ? count.intValue() : 0;
        } catch (Exception e) {
            throw new RuntimeException("Error contando total de vehículos", e);
        }
    }

    public List<Object[]> obtenerVehiculosPorMarca() {
        try {
            return em.createQuery(
                "SELECT m.nombreMarca, COUNT(v) FROM Vehiculo v JOIN v.iDMarca m GROUP BY m.nombreMarca", 
                Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo vehículos por marca", e);
        }
    }

    public List<Vehiculo> listarVehiculosConServiciosActivos() {
        try {
            return em.createQuery(
                "SELECT DISTINCT v FROM Vehiculo v JOIN v.ordenServicioList o WHERE o.fechaRealSalida IS NULL", 
                Vehiculo.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando vehículos con servicios activos", e);
        }
    }

    // Métodos adicionales útiles (mantenidos para compatibilidad)
    
    public Vehiculo findByPlaca(String placa) {
        try {
            List<Vehiculo> vehiculos = em.createQuery(
                "SELECT v FROM Vehiculo v WHERE v.placa = :placa", 
                Vehiculo.class)
                .setParameter("placa", placa)
                .getResultList();
            return vehiculos.isEmpty() ? null : vehiculos.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error buscando vehículo por placa", e);
        }
    }

    public boolean placaExists(String placa) {
        try {
            Long count = em.createQuery("SELECT COUNT(v) FROM Vehiculo v WHERE v.placa = :placa", Long.class)
                           .setParameter("placa", placa)
                           .getSingleResult();
            return count > 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando existencia de placa", e);
        }
    }

    public boolean numeroChasisExists(String numeroChasis) {
        try {
            Long count = em.createQuery("SELECT COUNT(v) FROM Vehiculo v WHERE v.numeroChasis = :numeroChasis", Long.class)
                           .setParameter("numeroChasis", numeroChasis)
                           .getSingleResult();
            return count > 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando existencia de número de chasis", e);
        }
    }

    @Transactional
    public void updateEstado(Integer id, Boolean estado) {
        try {
            Vehiculo vehiculo = em.find(Vehiculo.class, id);
            if (vehiculo != null) {
                vehiculo.setEstado(estado);
                em.merge(vehiculo);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando estado del vehículo", e);
        }
    }

    @Transactional
    public void updateKilometraje(Integer id, Integer kilometraje) {
        try {
            Vehiculo vehiculo = em.find(Vehiculo.class, id);
            if (vehiculo != null) {
                vehiculo.setKilometraje(kilometraje);
                em.merge(vehiculo);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando kilometraje del vehículo", e);
        }
    }

    public Long countVehiculosActivos() {
        try {
            return em.createQuery("SELECT COUNT(v) FROM Vehiculo v WHERE v.estado = true", Long.class)
                     .getSingleResult();
        } catch (Exception e) {
            throw new RuntimeException("Error contando vehículos activos", e);
        }
    }

    public Long countVehiculosPorMarca(Integer idMarca) {
        try {
            return em.createQuery("SELECT COUNT(v) FROM Vehiculo v WHERE v.iDMarca.iDMarca = :idMarca", Long.class)
                     .setParameter("idMarca", idMarca)
                     .getSingleResult();
        } catch (Exception e) {
            throw new RuntimeException("Error contando vehículos por marca", e);
        }
    }

    public List<Object[]> getVehiculosConDetallesCompletos() {
        try {
            return em.createQuery(
                "SELECT v, c, m, mod FROM Vehiculo v " +
                "JOIN v.iDCliente c " +
                "JOIN v.iDMarca m " +
                "JOIN v.iDModelo mod " +
                "WHERE v.estado = true", 
                Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo vehículos con detalles completos", e);
        }
    }

    public List<Vehiculo> findByPlacaContaining(String texto) {
        return buscarVehiculosPorPlaca(texto);
    }

    // CORRECCIÓN: Métodos adicionales mejorados
    
    public List<Vehiculo> listarVehiculosConDetallesCompletos() {
        try {
            return em.createQuery(
                "SELECT v FROM Vehiculo v " +
                "LEFT JOIN FETCH v.iDCliente " +
                "LEFT JOIN FETCH v.iDMarca " +
                "LEFT JOIN FETCH v.iDModelo " +
                "ORDER BY v.placa", 
                Vehiculo.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando vehículos con detalles completos", e);
        }
    }

    public Vehiculo obtenerVehiculoCompleto(int idVehiculo) {
        try {
            List<Vehiculo> vehiculos = em.createQuery(
                "SELECT v FROM Vehiculo v " +
                "LEFT JOIN FETCH v.iDCliente " +
                "LEFT JOIN FETCH v.iDMarca " +
                "LEFT JOIN FETCH v.iDModelo " +
                "LEFT JOIN FETCH v.ordenServicioList " +
                "WHERE v.iDVehiculo = :id", 
                Vehiculo.class)
                .setParameter("id", idVehiculo)
                .getResultList();
            return vehiculos.isEmpty() ? null : vehiculos.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo vehículo completo", e);
        }
    }

    public List<Vehiculo> buscarVehiculosPorCriterio(String criterio) {
        try {
            return em.createQuery(
                "SELECT v FROM Vehiculo v " +
                "LEFT JOIN v.iDCliente c " +
                "LEFT JOIN v.iDMarca m " +
                "LEFT JOIN v.iDModelo mod " +
                "WHERE v.placa LIKE :criterio " +
                "OR v.color LIKE :criterio " +
                "OR v.numeroChasis LIKE :criterio " +
                "OR c.nombre LIKE :criterio " +
                "OR c.apellido LIKE :criterio " +
                "OR m.nombreMarca LIKE :criterio " +
                "OR mod.nombreModelo LIKE :criterio " +
                "ORDER BY v.placa", 
                Vehiculo.class)
                .setParameter("criterio", "%" + criterio + "%")
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando vehículos por criterio", e);
        }
    }

    public List<Vehiculo> filtrarVehiculosPorAnio(int anioMin, int anioMax) {
        try {
            return em.createQuery(
                "SELECT v FROM Vehiculo v " +
                "WHERE v.anioVehiculo BETWEEN :anioMin AND :anioMax " +
                "AND v.estado = true " +
                "ORDER BY v.anioVehiculo DESC", 
                Vehiculo.class)
                .setParameter("anioMin", anioMin)
                .setParameter("anioMax", anioMax)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error filtrando vehículos por año", e);
        }
    }

    public List<Vehiculo> filtrarVehiculosPorKilometraje(int kmMin, int kmMax) {
        try {
            return em.createQuery(
                "SELECT v FROM Vehiculo v " +
                "WHERE v.kilometraje BETWEEN :kmMin AND :kmMax " +
                "AND v.estado = true " +
                "ORDER BY v.kilometraje ASC", 
                Vehiculo.class)
                .setParameter("kmMin", kmMin)
                .setParameter("kmMax", kmMax)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error filtrando vehículos por kilometraje", e);
        }
    }

    public List<Object[]> obtenerEstadisticasVehiculos() {
        try {
            return em.createQuery(
                "SELECT " +
                "COUNT(v) as totalVehiculos, " +
                "SUM(CASE WHEN v.estado = true THEN 1 ELSE 0 END) as vehiculosActivos, " +
                "AVG(v.anioVehiculo) as añoPromedio, " +
                "AVG(v.kilometraje) as kilometrajePromedio, " +
                "COUNT(DISTINCT v.iDMarca) as marcasDiferentes " +
                "FROM Vehiculo v", 
                Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estadísticas de vehículos", e);
        }
    }

    public List<Object[]> obtenerVehiculosMasVisitados(int limite) {
        try {
            return em.createQuery(
                "SELECT v.placa, m.nombreMarca, mod.nombreModelo, COUNT(o) as visitas " +
                "FROM Vehiculo v " +
                "JOIN v.iDMarca m " +
                "JOIN v.iDModelo mod " +
                "JOIN v.ordenServicioList o " +
                "GROUP BY v.placa, m.nombreMarca, mod.nombreModelo " +
                "ORDER BY COUNT(o) DESC", 
                Object[].class)
                .setMaxResults(limite)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo vehículos más visitados", e);
        }
    }

    public boolean puedeEliminarVehiculo(int idVehiculo) {
        try {
            // Verificar si tiene órdenes de servicio asociadas
            Long count = em.createQuery(
                "SELECT COUNT(o) FROM OrdenServicio o WHERE o.iDVehiculo.iDVehiculo = :idVehiculo", 
                Long.class)
                .setParameter("idVehiculo", idVehiculo)
                .getSingleResult();
            
            return count == 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando si se puede eliminar vehículo", e);
        }
    }

    @Transactional
    public boolean transferirVehiculo(int idVehiculo, int idNuevoCliente) {
        try {
            Vehiculo vehiculo = em.find(Vehiculo.class, idVehiculo);
            Cliente nuevoCliente = em.find(Cliente.class, idNuevoCliente);
            
            if (vehiculo != null && nuevoCliente != null) {
                vehiculo.setIDCliente(nuevoCliente);
                em.merge(vehiculo);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error transfiriendo vehículo", e);
        }
    }

    public List<Vehiculo> obtenerVehiculosSinServiciosRecientes(int meses) {
        try {
            return em.createQuery(
                "SELECT v FROM Vehiculo v " +
                "WHERE v.estado = true " +
                "AND NOT EXISTS (" +
                "   SELECT o FROM OrdenServicio o " +
                "   WHERE o.iDVehiculo.iDVehiculo = v.iDVehiculo " +
                "   AND o.fechaEntrada >= FUNCTION('DATE_SUB', CURRENT_DATE, :meses, 'MONTH')" +
                ") " +
                "ORDER BY v.placa", 
                Vehiculo.class)
                .setParameter("meses", meses)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo vehículos sin servicios recientes", e);
        }
    }
}