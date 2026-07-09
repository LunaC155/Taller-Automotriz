/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.upec.model;

import jakarta.persistence.Basic;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Lob;
import jakarta.persistence.NamedQueries;
import jakarta.persistence.NamedQuery;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import jakarta.xml.bind.annotation.XmlRootElement;
import jakarta.xml.bind.annotation.XmlTransient;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.List;

/**
 *
 * @author ACER NITRO V15
 */
@Entity
@Table(name = "servicio")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "Servicio.findAll", query = "SELECT s FROM Servicio s"),
    @NamedQuery(name = "Servicio.findByIDServicio", query = "SELECT s FROM Servicio s WHERE s.iDServicio = :iDServicio"),
    @NamedQuery(name = "Servicio.findByNombreServicio", query = "SELECT s FROM Servicio s WHERE s.nombreServicio = :nombreServicio"),
    @NamedQuery(name = "Servicio.findByPrecioBase", query = "SELECT s FROM Servicio s WHERE s.precioBase = :precioBase"),
    @NamedQuery(name = "Servicio.findByDuracionEstimada", query = "SELECT s FROM Servicio s WHERE s.duracionEstimada = :duracionEstimada"),
    @NamedQuery(name = "Servicio.findByEstado", query = "SELECT s FROM Servicio s WHERE s.estado = :estado")})
public class Servicio implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "ID_Servicio")
    private Integer iDServicio;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 100)
    @Column(name = "Nombre_Servicio")
    private String nombreServicio;
    @Lob
    @Size(max = 65535)
    @Column(name = "Descripcion")
    private String descripcion;
    // @Max(value=?)  @Min(value=?)//if you know range of your decimal fields consider using these annotations to enforce field validation
    @Column(name = "Precio_Base")
    private BigDecimal precioBase;
    @Column(name = "Duracion_Estimada")
    private Integer duracionEstimada;
    @Column(name = "Estado")
    private Boolean estado;
    @OneToMany(mappedBy = "iDServicio")
    private List<DetalleFactura> detalleFacturaList;

    public Servicio() {
    }

    public Servicio(Integer iDServicio) {
        this.iDServicio = iDServicio;
    }

    public Servicio(Integer iDServicio, String nombreServicio) {
        this.iDServicio = iDServicio;
        this.nombreServicio = nombreServicio;
    }

    public Integer getIDServicio() {
        return iDServicio;
    }

    public void setIDServicio(Integer iDServicio) {
        this.iDServicio = iDServicio;
    }

    public String getNombreServicio() {
        return nombreServicio;
    }

    public void setNombreServicio(String nombreServicio) {
        this.nombreServicio = nombreServicio;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public BigDecimal getPrecioBase() {
        return precioBase;
    }

    public void setPrecioBase(BigDecimal precioBase) {
        this.precioBase = precioBase;
    }

    public Integer getDuracionEstimada() {
        return duracionEstimada;
    }

    public void setDuracionEstimada(Integer duracionEstimada) {
        this.duracionEstimada = duracionEstimada;
    }

    public Boolean getEstado() {
        return estado;
    }

    public void setEstado(Boolean estado) {
        this.estado = estado;
    }

    @XmlTransient
    public List<DetalleFactura> getDetalleFacturaList() {
        return detalleFacturaList;
    }

    public void setDetalleFacturaList(List<DetalleFactura> detalleFacturaList) {
        this.detalleFacturaList = detalleFacturaList;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (iDServicio != null ? iDServicio.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Servicio)) {
            return false;
        }
        Servicio other = (Servicio) object;
        if ((this.iDServicio == null && other.iDServicio != null) || (this.iDServicio != null && !this.iDServicio.equals(other.iDServicio))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "com.upec.model.Servicio[ iDServicio=" + iDServicio + " ]";
    }
    
}
