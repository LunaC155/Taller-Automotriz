/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.upec.model;

import jakarta.persistence.Basic;
import jakarta.persistence.CascadeType;
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
import java.util.List;

/**
 *
 * @author ACER NITRO V15
 */
@Entity
@Table(name = "estado_factura")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "EstadoFactura.findAll", query = "SELECT e FROM EstadoFactura e"),
    @NamedQuery(name = "EstadoFactura.findByIDEstadoFactura", query = "SELECT e FROM EstadoFactura e WHERE e.iDEstadoFactura = :iDEstadoFactura"),
    @NamedQuery(name = "EstadoFactura.findByNombreEstado", query = "SELECT e FROM EstadoFactura e WHERE e.nombreEstado = :nombreEstado")})
public class EstadoFactura implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "ID_Estado_Factura")
    private Integer iDEstadoFactura;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 50)
    @Column(name = "Nombre_Estado")
    private String nombreEstado;
    @Lob
    @Size(max = 65535)
    @Column(name = "Descripcion")
    private String descripcion;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "iDEstadoFactura")
    private List<Factura> facturaList;

    public EstadoFactura() {
    }

    public EstadoFactura(Integer iDEstadoFactura) {
        this.iDEstadoFactura = iDEstadoFactura;
    }

    public EstadoFactura(Integer iDEstadoFactura, String nombreEstado) {
        this.iDEstadoFactura = iDEstadoFactura;
        this.nombreEstado = nombreEstado;
    }

    public Integer getIDEstadoFactura() {
        return iDEstadoFactura;
    }

    public void setIDEstadoFactura(Integer iDEstadoFactura) {
        this.iDEstadoFactura = iDEstadoFactura;
    }

    public String getNombreEstado() {
        return nombreEstado;
    }

    public void setNombreEstado(String nombreEstado) {
        this.nombreEstado = nombreEstado;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    @XmlTransient
    public List<Factura> getFacturaList() {
        return facturaList;
    }

    public void setFacturaList(List<Factura> facturaList) {
        this.facturaList = facturaList;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (iDEstadoFactura != null ? iDEstadoFactura.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof EstadoFactura)) {
            return false;
        }
        EstadoFactura other = (EstadoFactura) object;
        if ((this.iDEstadoFactura == null && other.iDEstadoFactura != null) || (this.iDEstadoFactura != null && !this.iDEstadoFactura.equals(other.iDEstadoFactura))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "com.upec.model.EstadoFactura[ iDEstadoFactura=" + iDEstadoFactura + " ]";
    }
    
}
