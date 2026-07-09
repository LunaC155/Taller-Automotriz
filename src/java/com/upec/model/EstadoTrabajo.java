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
@Table(name = "estado_trabajo")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "EstadoTrabajo.findAll", query = "SELECT e FROM EstadoTrabajo e"),
    @NamedQuery(name = "EstadoTrabajo.findByIDEstadoTrabajo", query = "SELECT e FROM EstadoTrabajo e WHERE e.iDEstadoTrabajo = :iDEstadoTrabajo"),
    @NamedQuery(name = "EstadoTrabajo.findByNombreEstado", query = "SELECT e FROM EstadoTrabajo e WHERE e.nombreEstado = :nombreEstado")})
public class EstadoTrabajo implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "ID_Estado_Trabajo")
    private Integer iDEstadoTrabajo;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 50)
    @Column(name = "Nombre_Estado")
    private String nombreEstado;
    @Lob
    @Size(max = 65535)
    @Column(name = "Descripcion")
    private String descripcion;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "iDEstadoTrabajo")
    private List<OrdenServicio> ordenServicioList;

    public EstadoTrabajo() {
    }

    public EstadoTrabajo(Integer iDEstadoTrabajo) {
        this.iDEstadoTrabajo = iDEstadoTrabajo;
    }

    public EstadoTrabajo(Integer iDEstadoTrabajo, String nombreEstado) {
        this.iDEstadoTrabajo = iDEstadoTrabajo;
        this.nombreEstado = nombreEstado;
    }

    public Integer getIDEstadoTrabajo() {
        return iDEstadoTrabajo;
    }

    public void setIDEstadoTrabajo(Integer iDEstadoTrabajo) {
        this.iDEstadoTrabajo = iDEstadoTrabajo;
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
    public List<OrdenServicio> getOrdenServicioList() {
        return ordenServicioList;
    }

    public void setOrdenServicioList(List<OrdenServicio> ordenServicioList) {
        this.ordenServicioList = ordenServicioList;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (iDEstadoTrabajo != null ? iDEstadoTrabajo.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof EstadoTrabajo)) {
            return false;
        }
        EstadoTrabajo other = (EstadoTrabajo) object;
        if ((this.iDEstadoTrabajo == null && other.iDEstadoTrabajo != null) || (this.iDEstadoTrabajo != null && !this.iDEstadoTrabajo.equals(other.iDEstadoTrabajo))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "com.upec.model.EstadoTrabajo[ iDEstadoTrabajo=" + iDEstadoTrabajo + " ]";
    }
    
}