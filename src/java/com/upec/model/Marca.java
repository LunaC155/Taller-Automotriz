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
@Table(name = "marca")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "Marca.findAll", query = "SELECT m FROM Marca m"),
    @NamedQuery(name = "Marca.findByIDMarca", query = "SELECT m FROM Marca m WHERE m.iDMarca = :iDMarca"),
    @NamedQuery(name = "Marca.findByNombreMarca", query = "SELECT m FROM Marca m WHERE m.nombreMarca = :nombreMarca"),
    @NamedQuery(name = "Marca.findByEstado", query = "SELECT m FROM Marca m WHERE m.estado = :estado")})
public class Marca implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "ID_Marca")
    private Integer iDMarca;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 50)
    @Column(name = "Nombre_Marca")
    private String nombreMarca;
    @Lob
    @Size(max = 65535)
    @Column(name = "Descripcion")
    private String descripcion;
    @Column(name = "Estado")
    private Boolean estado;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "iDMarca")
    private List<Vehiculo> vehiculoList;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "iDMarca")
    private List<Modelo> modeloList;

    public Marca() {
    }

    public Marca(Integer iDMarca) {
        this.iDMarca = iDMarca;
    }

    public Marca(Integer iDMarca, String nombreMarca) {
        this.iDMarca = iDMarca;
        this.nombreMarca = nombreMarca;
    }

    public Integer getIDMarca() {
        return iDMarca;
    }

    public void setIDMarca(Integer iDMarca) {
        this.iDMarca = iDMarca;
    }

    public String getNombreMarca() {
        return nombreMarca;
    }

    public void setNombreMarca(String nombreMarca) {
        this.nombreMarca = nombreMarca;
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

    @XmlTransient
    public List<Modelo> getModeloList() {
        return modeloList;
    }

    public void setModeloList(List<Modelo> modeloList) {
        this.modeloList = modeloList;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (iDMarca != null ? iDMarca.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Marca)) {
            return false;
        }
        Marca other = (Marca) object;
        if ((this.iDMarca == null && other.iDMarca != null) || (this.iDMarca != null && !this.iDMarca.equals(other.iDMarca))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "com.upec.model.Marca[ iDMarca=" + iDMarca + " ]";
    }
    
}
