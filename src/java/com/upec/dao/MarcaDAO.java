package com.upec.dao;

import com.upec.model.Marca;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;
import java.util.List;

@Stateless
public class MarcaDAO {

    @PersistenceContext(unitName = "taller_automotrizPU")
    private EntityManager em;

    public List<Marca> listarMarcas() {
        try {
            return em.createQuery("SELECT m FROM Marca m ORDER BY m.nombreMarca", Marca.class).getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando marcas", e);
        }
    }

    public Marca obtenerMarcaPorId(int id) {
        try {
            return em.find(Marca.class, id);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo marca por ID", e);
        }
    }

    @Transactional
    public boolean crearMarca(Marca marca) {
        try {
            em.persist(marca);
            return true;
        } catch (Exception e) {
            throw new RuntimeException("Error creando marca", e);
        }
    }

    @Transactional
    public boolean actualizarMarca(Marca marca) {
        try {
            em.merge(marca);
            return true;
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando marca", e);
        }
    }

    @Transactional
    public boolean eliminarMarca(int id) {
        try {
            Marca marca = em.find(Marca.class, id);
            if (marca != null) {
                // Verificar si hay vehículos o modelos asociados
                if (!puedeEliminarMarca(id)) {
                    return false;
                }
                em.remove(marca);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error eliminando marca", e);
        }
    }

    public List<Marca> listarMarcasActivas() {
        try {
            return em.createQuery("SELECT m FROM Marca m WHERE m.estado = true ORDER BY m.nombreMarca", Marca.class)
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando marcas activas", e);
        }
    }

    // Métodos adicionales útiles (mantenidos para compatibilidad)
    
    @Transactional
    public void create(Marca marca) {
        try {
            em.persist(marca);
        } catch (Exception e) {
            throw new RuntimeException("Error al crear marca", e);
        }
    }

    @Transactional
    public void saveOrUpdate(Marca marca) {
        try {
            if (marca.getIDMarca() == null) {
                em.persist(marca);
            } else {
                em.merge(marca);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error guardando marca", e);
        }
    }

    public Marca findById(Integer id) {
        return obtenerMarcaPorId(id);
    }

    public List<Marca> findAll() {
        return listarMarcas();
    }

    public List<Marca> findByEstado(Boolean estado) {
        try {
            return em.createQuery("SELECT m FROM Marca m WHERE m.estado = :estado ORDER BY m.nombreMarca", Marca.class)
                     .setParameter("estado", estado)
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando marcas por estado", e);
        }
    }

    public Marca findByNombreMarca(String nombreMarca) {
        try {
            List<Marca> marcas = em.createQuery(
                "SELECT m FROM Marca m WHERE m.nombreMarca = :nombreMarca", 
                Marca.class)
                .setParameter("nombreMarca", nombreMarca)
                .getResultList();
            return marcas.isEmpty() ? null : marcas.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error buscando marca por nombre", e);
        }
    }

    public boolean nombreMarcaExists(String nombreMarca) {
        try {
            Long count = em.createQuery("SELECT COUNT(m) FROM Marca m WHERE m.nombreMarca = :nombreMarca", Long.class)
                           .setParameter("nombreMarca", nombreMarca)
                           .getSingleResult();
            return count > 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando existencia de nombre de marca", e);
        }
    }

    @Transactional
    public void delete(Integer id) {
        try {
            Marca marca = em.find(Marca.class, id);
            if (marca != null) {
                em.remove(marca);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error eliminando marca", e);
        }
    }

    @Transactional
    public void updateEstado(Integer id, Boolean estado) {
        try {
            Marca marca = em.find(Marca.class, id);
            if (marca != null) {
                marca.setEstado(estado);
                em.merge(marca);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando estado de la marca", e);
        }
    }

    public List<Marca> findMarcasActivas() {
        return listarMarcasActivas();
    }

    public Long countMarcasActivas() {
        try {
            return em.createQuery("SELECT COUNT(m) FROM Marca m WHERE m.estado = true", Long.class)
                     .getSingleResult();
        } catch (Exception e) {
            throw new RuntimeException("Error contando marcas activas", e);
        }
    }

    public List<Marca> findByDescripcionContaining(String texto) {
        try {
            return em.createQuery("SELECT m FROM Marca m WHERE m.descripcion LIKE :texto AND m.estado = true ORDER BY m.nombreMarca", Marca.class)
                     .setParameter("texto", "%" + texto + "%")
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando marcas por descripción", e);
        }
    }

    public List<Object[]> countVehiculosPorMarca() {
        try {
            return em.createQuery(
                "SELECT m.nombreMarca, COUNT(v) FROM Marca m LEFT JOIN m.vehiculoList v WHERE m.estado = true GROUP BY m.nombreMarca ORDER BY COUNT(v) DESC", 
                Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error contando vehículos por marca", e);
        }
    }

    public List<Object[]> countModelosPorMarca() {
        try {
            return em.createQuery(
                "SELECT m.nombreMarca, COUNT(mod) FROM Marca m LEFT JOIN m.modeloList mod WHERE m.estado = true GROUP BY m.nombreMarca ORDER BY COUNT(mod) DESC", 
                Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error contando modelos por marca", e);
        }
    }

    // Métodos adicionales útiles
    
    public boolean puedeEliminarMarca(int idMarca) {
        try {
            // Verificar si hay vehículos o modelos asociados
            Long countVehiculos = em.createQuery(
                "SELECT COUNT(v) FROM Vehiculo v WHERE v.iDMarca.iDMarca = :idMarca", 
                Long.class)
                .setParameter("idMarca", idMarca)
                .getSingleResult();
            
            Long countModelos = em.createQuery(
                "SELECT COUNT(m) FROM Modelo m WHERE m.iDMarca.iDMarca = :idMarca", 
                Long.class)
                .setParameter("idMarca", idMarca)
                .getSingleResult();
            
            return countVehiculos == 0 && countModelos == 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando si se puede eliminar marca", e);
        }
    }

    public List<Marca> buscarMarcasPorNombre(String nombre) {
        try {
            return em.createQuery(
                "SELECT m FROM Marca m WHERE m.nombreMarca LIKE :nombre AND m.estado = true ORDER BY m.nombreMarca", 
                Marca.class)
                .setParameter("nombre", "%" + nombre + "%")
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando marcas por nombre", e);
        }
    }

    public List<Marca> listarMarcasConVehiculos() {
        try {
            return em.createQuery(
                "SELECT DISTINCT m FROM Marca m JOIN m.vehiculoList v WHERE m.estado = true ORDER BY m.nombreMarca", 
                Marca.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando marcas con vehículos", e);
        }
    }

    public List<Marca> listarMarcasPopulares(int limite) {
        try {
            return em.createQuery(
                "SELECT m FROM Marca m WHERE m.estado = true AND SIZE(m.vehiculoList) > 0 ORDER BY SIZE(m.vehiculoList) DESC", 
                Marca.class)
                .setMaxResults(limite)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando marcas populares", e);
        }
    }

    // CORRECCIÓN: Métodos adicionales mejorados
    
    public List<Marca> listarMarcasConDetallesCompletos() {
        try {
            return em.createQuery(
                "SELECT m FROM Marca m " +
                "LEFT JOIN FETCH m.vehiculoList " +
                "LEFT JOIN FETCH m.modeloList " +
                "WHERE m.estado = true " +
                "ORDER BY m.nombreMarca", 
                Marca.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando marcas con detalles completos", e);
        }
    }

    public Marca obtenerMarcaConModelos(int idMarca) {
        try {
            List<Marca> marcas = em.createQuery(
                "SELECT m FROM Marca m " +
                "LEFT JOIN FETCH m.modeloList mod " +
                "WHERE m.iDMarca = :id AND m.estado = true", 
                Marca.class)
                .setParameter("id", idMarca)
                .getResultList();
            return marcas.isEmpty() ? null : marcas.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo marca con modelos", e);
        }
    }

    public Marca obtenerMarcaConVehiculos(int idMarca) {
        try {
            List<Marca> marcas = em.createQuery(
                "SELECT m FROM Marca m " +
                "LEFT JOIN FETCH m.vehiculoList v " +
                "WHERE m.iDMarca = :id AND m.estado = true", 
                Marca.class)
                .setParameter("id", idMarca)
                .getResultList();
            return marcas.isEmpty() ? null : marcas.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo marca con vehículos", e);
        }
    }

    public List<Marca> buscarMarcasPorCriterio(String criterio) {
        try {
            return em.createQuery(
                "SELECT m FROM Marca m " +
                "WHERE (m.nombreMarca LIKE :criterio OR m.descripcion LIKE :criterio) " +
                "AND m.estado = true " +
                "ORDER BY m.nombreMarca", 
                Marca.class)
                .setParameter("criterio", "%" + criterio + "%")
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando marcas por criterio", e);
        }
    }

    @Transactional
    public boolean activarMarca(int idMarca) {
        try {
            Marca marca = em.find(Marca.class, idMarca);
            if (marca != null) {
                marca.setEstado(true);
                em.merge(marca);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error activando marca", e);
        }
    }

    @Transactional
    public boolean desactivarMarca(int idMarca) {
        try {
            Marca marca = em.find(Marca.class, idMarca);
            if (marca != null) {
                marca.setEstado(false);
                em.merge(marca);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error desactivando marca", e);
        }
    }

    public List<Object[]> obtenerEstadisticasMarcas() {
        try {
            return em.createQuery(
                "SELECT m.nombreMarca, " +
                "COUNT(DISTINCT v) as totalVehiculos, " +
                "COUNT(DISTINCT mod) as totalModelos, " +
                "CASE WHEN m.estado = true THEN 'Activa' ELSE 'Inactiva' END as estado " +
                "FROM Marca m " +
                "LEFT JOIN m.vehiculoList v " +
                "LEFT JOIN m.modeloList mod " +
                "GROUP BY m.nombreMarca, m.estado " +
                "ORDER BY totalVehiculos DESC", 
                Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estadísticas de marcas", e);
        }
    }

    public boolean existeMarcaConNombre(String nombreMarca) {
        try {
            Long count = em.createQuery(
                "SELECT COUNT(m) FROM Marca m WHERE m.nombreMarca = :nombreMarca", 
                Long.class)
                .setParameter("nombreMarca", nombreMarca)
                .getSingleResult();
            return count > 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando existencia de marca con nombre", e);
        }
    }

    @Transactional
    public Marca crearMarcaSiNoExiste(String nombreMarca, String descripcion) {
        try {
            // Verificar si ya existe la marca
            Marca marcaExistente = findByNombreMarca(nombreMarca);
            if (marcaExistente != null) {
                return marcaExistente;
            }

            // Crear nueva marca
            Marca nuevaMarca = new Marca();
            nuevaMarca.setNombreMarca(nombreMarca);
            nuevaMarca.setDescripcion(descripcion);
            nuevaMarca.setEstado(true);
            
            em.persist(nuevaMarca);
            return nuevaMarca;
        } catch (Exception e) {
            throw new RuntimeException("Error creando marca si no existe", e);
        }
    }
}