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
import jakarta.persistence.JoinColumn;
import jakarta.persistence.Lob;
import jakarta.persistence.ManyToOne;
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
@Table(name = "modelo")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "Modelo.findAll", query = "SELECT m FROM Modelo m"),
    @NamedQuery(name = "Modelo.findByIDModelo", query = "SELECT m FROM Modelo m WHERE m.iDModelo = :iDModelo"),
    @NamedQuery(name = "Modelo.findByNombreModelo", query = "SELECT m FROM Modelo m WHERE m.nombreModelo = :nombreModelo"),
    @NamedQuery(name = "Modelo.findByAnio", query = "SELECT m FROM Modelo m WHERE m.anio = :anio"),
    @NamedQuery(name = "Modelo.findByEstado", query = "SELECT m FROM Modelo m WHERE m.estado = :estado")})
public class Modelo implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "ID_Modelo")
    private Integer iDModelo;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 50)
    @Column(name = "Nombre_Modelo")
    private String nombreModelo;
    @Column(name = "Anio")
    private Integer anio;
    @Lob
    @Size(max = 65535)
    @Column(name = "Descripcion")
    private String descripcion;
    @Column(name = "Estado")
    private Boolean estado;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "iDModelo")
    private List<Vehiculo> vehiculoList;
    @JoinColumn(name = "ID_Marca", referencedColumnName = "ID_Marca")
    @ManyToOne(optional = false)
    private Marca iDMarca;

    public Modelo() {
    }

    public Modelo(Integer iDModelo) {
        this.iDModelo = iDModelo;
    }

    public Modelo(Integer iDModelo, String nombreModelo) {
        this.iDModelo = iDModelo;
        this.nombreModelo = nombreModelo;
    }

    public Integer getIDModelo() {
        return iDModelo;
    }

    public void setIDModelo(Integer iDModelo) {
        this.iDModelo = iDModelo;
    }

    public String getNombreModelo() {
        return nombreModelo;
    }

    public void setNombreModelo(String nombreModelo) {
        this.nombreModelo = nombreModelo;
    }

    public Integer getAnio() {
        return anio;
    }

    public void setAnio(Integer anio) {
        this.anio = anio;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public Boolean getEstado() {
        return estado;
    }

    public void setEstado(Boolean estado) {
        this.estado = estado;
    }

    @XmlTransient
    public List<Vehiculo> getVehiculoList() {
        return vehiculoList;
    }

    public void setVehiculoList(List<Vehiculo> vehiculoList) {
        this.vehiculoList = vehiculoList;
    }

    public Marca getIDMarca() {
        return iDMarca;
    }

    public void setIDMarca(Marca iDMarca) {
        this.iDMarca = iDMarca;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (iDModelo != null ? iDModelo.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Modelo)) {
            return false;
        }
        Modelo other = (Modelo) object;
        if ((this.iDModelo == null && other.iDModelo != null) || (this.iDModelo != null && !this.iDModelo.equals(other.iDModelo))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "com.upec.model.Modelo[ iDModelo=" + iDModelo + " ]";
    }
    
}
