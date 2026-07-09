package com.upec.dao;

import com.upec.model.Modelo;
import com.upec.model.Marca;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;
import java.util.List;

@Stateless
public class ModeloDAO {

    @PersistenceContext(unitName = "taller_automotrizPU")
    private EntityManager em;

    public List<Modelo> listarModelos() {
        try {
            return em.createQuery("SELECT m FROM Modelo m ORDER BY m.nombreModelo", Modelo.class).getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando modelos", e);
        }
    }

    public Modelo obtenerModeloPorId(int id) {
        try {
            return em.find(Modelo.class, id);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo modelo por ID", e);
        }
    }

    public List<Modelo> listarModelosPorMarca(int idMarca) {
        try {
            return em.createQuery(
                "SELECT m FROM Modelo m WHERE m.iDMarca.iDMarca = :idMarca ORDER BY m.nombreModelo", 
                Modelo.class)
                .setParameter("idMarca", idMarca)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando modelos por marca", e);
        }
    }

    @Transactional
    public boolean crearModelo(Modelo modelo) {
        try {
            em.persist(modelo);
            return true;
        } catch (Exception e) {
            throw new RuntimeException("Error creando modelo", e);
        }
    }

    @Transactional
    public boolean actualizarModelo(Modelo modelo) {
        try {
            em.merge(modelo);
            return true;
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando modelo", e);
        }
    }

    @Transactional
    public boolean eliminarModelo(int id) {
        try {
            Modelo modelo = em.find(Modelo.class, id);
            if (modelo != null) {
                // Verificar si hay vehículos asociados
                if (!puedeEliminarModelo(id)) {
                    return false;
                }
                em.remove(modelo);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error eliminando modelo", e);
        }
    }

    // Métodos adicionales útiles
    
    public List<Modelo> listarModelosActivos() {
        try {
            return em.createQuery(
                "SELECT m FROM Modelo m WHERE m.estado = true ORDER BY m.nombreModelo", 
                Modelo.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando modelos activos", e);
        }
    }

    public List<Modelo> listarModelosActivosPorMarca(int idMarca) {
        try {
            return em.createQuery(
                "SELECT m FROM Modelo m WHERE m.iDMarca.iDMarca = :idMarca AND m.estado = true ORDER BY m.nombreModelo", 
                Modelo.class)
                .setParameter("idMarca", idMarca)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando modelos activos por marca", e);
        }
    }

    public Modelo obtenerModeloConMarca(int idModelo) {
        try {
            List<Modelo> modelos = em.createQuery(
                "SELECT m FROM Modelo m LEFT JOIN FETCH m.iDMarca WHERE m.iDModelo = :id", 
                Modelo.class)
                .setParameter("id", idModelo)
                .getResultList();
            return modelos.isEmpty() ? null : modelos.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo modelo con marca", e);
        }
    }

    public List<Modelo> buscarModelosPorNombre(String nombre) {
        try {
            return em.createQuery(
                "SELECT m FROM Modelo m WHERE m.nombreModelo LIKE :nombre AND m.estado = true ORDER BY m.nombreModelo", 
                Modelo.class)
                .setParameter("nombre", "%" + nombre + "%")
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando modelos por nombre", e);
        }
    }

    public List<Modelo> buscarModelosPorDescripcion(String descripcion) {
        try {
            return em.createQuery(
                "SELECT m FROM Modelo m WHERE m.descripcion LIKE :descripcion AND m.estado = true ORDER BY m.nombreModelo", 
                Modelo.class)
                .setParameter("descripcion", "%" + descripcion + "%")
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando modelos por descripción", e);
        }
    }

    public List<Modelo> listarModelosPorAnio(int anio) {
        try {
            return em.createQuery(
                "SELECT m FROM Modelo m WHERE m.anio = :anio AND m.estado = true ORDER BY m.nombreModelo", 
                Modelo.class)
                .setParameter("anio", anio)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando modelos por año", e);
        }
    }

    public List<Modelo> listarModelosPorRangoAnio(int anioInicio, int anioFin) {
        try {
            return em.createQuery(
                "SELECT m FROM Modelo m WHERE m.anio BETWEEN :anioInicio AND :anioFin AND m.estado = true ORDER BY m.anio, m.nombreModelo", 
                Modelo.class)
                .setParameter("anioInicio", anioInicio)
                .setParameter("anioFin", anioFin)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando modelos por rango de año", e);
        }
    }

    public boolean existeModeloConNombreYMarca(String nombreModelo, int idMarca) {
        try {
            Long count = em.createQuery(
                "SELECT COUNT(m) FROM Modelo m WHERE m.nombreModelo = :nombreModelo AND m.iDMarca.iDMarca = :idMarca", 
                Long.class)
                .setParameter("nombreModelo", nombreModelo)
                .setParameter("idMarca", idMarca)
                .getSingleResult();
            return count > 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando existencia de modelo con nombre y marca", e);
        }
    }

    public boolean puedeEliminarModelo(int idModelo) {
        try {
            Long count = em.createQuery(
                "SELECT COUNT(v) FROM Vehiculo v WHERE v.iDModelo.iDModelo = :idModelo", 
                Long.class)
                .setParameter("idModelo", idModelo)
                .getSingleResult();
            return count == 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando si se puede eliminar modelo", e);
        }
    }

    public Long contarModelosActivos() {
        try {
            return em.createQuery("SELECT COUNT(m) FROM Modelo m WHERE m.estado = true", Long.class)
                     .getSingleResult();
        } catch (Exception e) {
            throw new RuntimeException("Error contando modelos activos", e);
        }
    }

    public Long contarModelosPorMarca(int idMarca) {
        try {
            return em.createQuery(
                "SELECT COUNT(m) FROM Modelo m WHERE m.iDMarca.iDMarca = :idMarca AND m.estado = true", 
                Long.class)
                .setParameter("idMarca", idMarca)
                .getSingleResult();
        } catch (Exception e) {
            throw new RuntimeException("Error contando modelos por marca", e);
        }
    }

    public List<Object[]> contarVehiculosPorModelo() {
        try {
            return em.createQuery(
                "SELECT m.nombreModelo, COUNT(v) FROM Modelo m LEFT JOIN m.vehiculoList v WHERE m.estado = true GROUP BY m.nombreModelo ORDER BY COUNT(v) DESC", 
                Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error contando vehículos por modelo", e);
        }
    }

    public List<Object[]> contarModelosPorMarca() {
        try {
            return em.createQuery(
                "SELECT ma.nombreMarca, COUNT(mo) FROM Marca ma LEFT JOIN ma.modeloList mo WHERE ma.estado = true GROUP BY ma.nombreMarca ORDER BY COUNT(mo) DESC", 
                Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error contando modelos por marca", e);
        }
    }

    public List<Modelo> listarModelosPopulares(int limite) {
        try {
            return em.createQuery(
                "SELECT m FROM Modelo m WHERE m.estado = true AND SIZE(m.vehiculoList) > 0 ORDER BY SIZE(m.vehiculoList) DESC", 
                Modelo.class)
                .setMaxResults(limite)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando modelos populares", e);
        }
    }

    // Métodos para compatibilidad con código existente
    
    @Transactional
    public void create(Modelo modelo) {
        try {
            em.persist(modelo);
        } catch (Exception e) {
            throw new RuntimeException("Error al crear modelo", e);
        }
    }

    @Transactional
    public void saveOrUpdate(Modelo modelo) {
        try {
            if (modelo.getIDModelo() == null) {
                em.persist(modelo);
            } else {
                em.merge(modelo);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error guardando modelo", e);
        }
    }

    public Modelo findById(Integer id) {
        return obtenerModeloPorId(id);
    }

    public List<Modelo> findAll() {
        return listarModelos();
    }

    public Modelo findByNombreModelo(String nombreModelo) {
        try {
            List<Modelo> modelos = em.createQuery(
                "SELECT m FROM Modelo m WHERE m.nombreModelo = :nombreModelo", 
                Modelo.class)
                .setParameter("nombreModelo", nombreModelo)
                .getResultList();
            return modelos.isEmpty() ? null : modelos.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error buscando modelo por nombre", e);
        }
    }

    public boolean nombreModeloExists(String nombreModelo) {
        try {
            Long count = em.createQuery(
                "SELECT COUNT(m) FROM Modelo m WHERE m.nombreModelo = :nombreModelo", 
                Long.class)
                .setParameter("nombreModelo", nombreModelo)
                .getSingleResult();
            return count > 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando existencia de nombre de modelo", e);
        }
    }

    @Transactional
    public void delete(Integer id) {
        try {
            Modelo modelo = em.find(Modelo.class, id);
            if (modelo != null) {
                em.remove(modelo);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error eliminando modelo", e);
        }
    }

    @Transactional
    public void updateEstado(Integer id, Boolean estado) {
        try {
            Modelo modelo = em.find(Modelo.class, id);
            if (modelo != null) {
                modelo.setEstado(estado);
                em.merge(modelo);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando estado del modelo", e);
        }
    }

    // CORRECCIÓN: Métodos adicionales mejorados
    
    public List<Modelo> listarModelosConDetallesCompletos() {
        try {
            return em.createQuery(
                "SELECT m FROM Modelo m " +
                "LEFT JOIN FETCH m.iDMarca " +
                "LEFT JOIN FETCH m.vehiculoList " +
                "WHERE m.estado = true " +
                "ORDER BY m.iDMarca.nombreMarca, m.nombreModelo", 
                Modelo.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando modelos con detalles completos", e);
        }
    }

    public Modelo obtenerModeloConVehiculos(int idModelo) {
        try {
            List<Modelo> modelos = em.createQuery(
                "SELECT m FROM Modelo m " +
                "LEFT JOIN FETCH m.vehiculoList v " +
                "LEFT JOIN FETCH v.iDCliente " +
                "WHERE m.iDModelo = :id", 
                Modelo.class)
                .setParameter("id", idModelo)
                .getResultList();
            return modelos.isEmpty() ? null : modelos.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo modelo con vehículos", e);
        }
    }

    public List<Modelo> buscarModelosPorCriterio(String criterio) {
        try {
            return em.createQuery(
                "SELECT m FROM Modelo m " +
                "LEFT JOIN m.iDMarca ma " +
                "WHERE (m.nombreModelo LIKE :criterio " +
                "OR m.descripcion LIKE :criterio " +
                "OR ma.nombreMarca LIKE :criterio) " +
                "AND m.estado = true " +
                "ORDER BY ma.nombreMarca, m.nombreModelo", 
                Modelo.class)
                .setParameter("criterio", "%" + criterio + "%")
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando modelos por criterio", e);
        }
    }

    @Transactional
    public boolean activarModelo(int idModelo) {
        try {
            Modelo modelo = em.find(Modelo.class, idModelo);
            if (modelo != null) {
                modelo.setEstado(true);
                em.merge(modelo);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error activando modelo", e);
        }
    }

    @Transactional
    public boolean desactivarModelo(int idModelo) {
        try {
            Modelo modelo = em.find(Modelo.class, idModelo);
            if (modelo != null) {
                modelo.setEstado(false);
                em.merge(modelo);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error desactivando modelo", e);
        }
    }

    public List<Object[]> obtenerEstadisticasModelos() {
        try {
            return em.createQuery(
                "SELECT m.nombreModelo, " +
                "ma.nombreMarca, " +
                "COUNT(DISTINCT v) as totalVehiculos, " +
                "m.anio, " +
                "CASE WHEN m.estado = true THEN 'Activo' ELSE 'Inactivo' END as estado " +
                "FROM Modelo m " +
                "LEFT JOIN m.iDMarca ma " +
                "LEFT JOIN m.vehiculoList v " +
                "GROUP BY m.nombreModelo, ma.nombreMarca, m.anio, m.estado " +
                "ORDER BY totalVehiculos DESC", 
                Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estadísticas de modelos", e);
        }
    }

    public boolean existeModeloConNombre(String nombreModelo) {
        try {
            Long count = em.createQuery(
                "SELECT COUNT(m) FROM Modelo m WHERE m.nombreModelo = :nombreModelo", 
                Long.class)
                .setParameter("nombreModelo", nombreModelo)
                .getSingleResult();
            return count > 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando existencia de modelo con nombre", e);
        }
    }

    @Transactional
    public Modelo crearModeloSiNoExiste(String nombreModelo, Marca marca, Integer anio, String descripcion) {
        try {
            // Verificar si ya existe el modelo
            Modelo modeloExistente = em.createQuery(
                "SELECT m FROM Modelo m WHERE m.nombreModelo = :nombreModelo AND m.iDMarca = :marca", 
                Modelo.class)
                .setParameter("nombreModelo", nombreModelo)
                .setParameter("marca", marca)
                .getResultStream()
                .findFirst()
                .orElse(null);

            if (modeloExistente != null) {
                return modeloExistente;
            }

            // Crear nuevo modelo
            Modelo nuevoModelo = new Modelo();
            nuevoModelo.setNombreModelo(nombreModelo);
            nuevoModelo.setIDMarca(marca);
            nuevoModelo.setAnio(anio);
            nuevoModelo.setDescripcion(descripcion);
            nuevoModelo.setEstado(true);
            
            em.persist(nuevoModelo);
            return nuevoModelo;
        } catch (Exception e) {
            throw new RuntimeException("Error creando modelo si no existe", e);
        }
    }

    public List<Modelo> obtenerModelosPorMarcaYAnio(int idMarca, int anio) {
        try {
            return em.createQuery(
                "SELECT m FROM Modelo m " +
                "WHERE m.iDMarca.iDMarca = :idMarca " +
                "AND m.anio = :anio " +
                "AND m.estado = true " +
                "ORDER BY m.nombreModelo", 
                Modelo.class)
                .setParameter("idMarca", idMarca)
                .setParameter("anio", anio)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo modelos por marca y año", e);
        }
    }
}