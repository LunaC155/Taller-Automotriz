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
@Table(name = "vehiculo")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "Vehiculo.findAll", query = "SELECT v FROM Vehiculo v"),
    @NamedQuery(name = "Vehiculo.findByIDVehiculo", query = "SELECT v FROM Vehiculo v WHERE v.iDVehiculo = :iDVehiculo"),
    @NamedQuery(name = "Vehiculo.findByPlaca", query = "SELECT v FROM Vehiculo v WHERE v.placa = :placa"),
    @NamedQuery(name = "Vehiculo.findByColor", query = "SELECT v FROM Vehiculo v WHERE v.color = :color"),
    @NamedQuery(name = "Vehiculo.findByAnioVehiculo", query = "SELECT v FROM Vehiculo v WHERE v.anioVehiculo = :anioVehiculo"),
    @NamedQuery(name = "Vehiculo.findByNumeroChasis", query = "SELECT v FROM Vehiculo v WHERE v.numeroChasis = :numeroChasis"),
    @NamedQuery(name = "Vehiculo.findByKilometraje", query = "SELECT v FROM Vehiculo v WHERE v.kilometraje = :kilometraje"),
    @NamedQuery(name = "Vehiculo.findByEstado", query = "SELECT v FROM Vehiculo v WHERE v.estado = :estado")})
public class Vehiculo implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "ID_Vehiculo")
    private Integer iDVehiculo;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 20)
    @Column(name = "Placa")
    private String placa;
    @Size(max = 30)
    @Column(name = "Color")
    private String color;
    @Column(name = "Anio_Vehiculo")
    private Integer anioVehiculo;
    @Size(max = 100)
    @Column(name = "Numero_Chasis")
    private String numeroChasis;
    @Column(name = "Kilometraje")
    private Integer kilometraje;
    @Column(name = "Estado")
    private Boolean estado;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "iDVehiculo")
    private List<OrdenServicio> ordenServicioList;
    @JoinColumn(name = "ID_Cliente", referencedColumnName = "ID_Cliente")
    @ManyToOne(optional = false)
    private Cliente iDCliente;
    @JoinColumn(name = "ID_Marca", referencedColumnName = "ID_Marca")
    @ManyToOne(optional = false)
    private Marca iDMarca;
    @JoinColumn(name = "ID_Modelo", referencedColumnName = "ID_Modelo")
    @ManyToOne(optional = false)
    private Modelo iDModelo;

    public Vehiculo() {
    }

    public Vehiculo(Integer iDVehiculo) {
        this.iDVehiculo = iDVehiculo;
    }

    public Vehiculo(Integer iDVehiculo, String placa) {
        this.iDVehiculo = iDVehiculo;
        this.placa = placa;
    }

    public Integer getIDVehiculo() {
        return iDVehiculo;
    }

    public void setIDVehiculo(Integer iDVehiculo) {
        this.iDVehiculo = iDVehiculo;
    }

    public String getPlaca() {
        return placa;
    }

    public void setPlaca(String placa) {
        this.placa = placa;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public Integer getAnioVehiculo() {
        return anioVehiculo;
    }

    public void setAnioVehiculo(Integer anioVehiculo) {
        this.anioVehiculo = anioVehiculo;
    }

    public String getNumeroChasis() {
        return numeroChasis;
    }

    public void setNumeroChasis(String numeroChasis) {
        this.numeroChasis = numeroChasis;
    }

    public Integer getKilometraje() {
        return kilometraje;
    }

    public void setKilometraje(Integer kilometraje) {
        this.kilometraje = kilometraje;
    }

    public Boolean getEstado() {
        return estado;
    }

    public void setEstado(Boolean estado) {
        this.estado = estado;
    }

    @XmlTransient
    public List<OrdenServicio> getOrdenServicioList() {
        return ordenServicioList;
    }

    public void setOrdenServicioList(List<OrdenServicio> ordenServicioList) {
        this.ordenServicioList = ordenServicioList;
    }

    public Cliente getIDCliente() {
        return iDCliente;
    }

    public void setIDCliente(Cliente iDCliente) {
        this.iDCliente = iDCliente;
    }

    public Marca getIDMarca() {
        return iDMarca;
    }

    public void setIDMarca(Marca iDMarca) {
        this.iDMarca = iDMarca;
    }

    public Modelo getIDModelo() {
        return iDModelo;
    }

    public void setIDModelo(Modelo iDModelo) {
        this.iDModelo = iDModelo;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (iDVehiculo != null ? iDVehiculo.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Vehiculo)) {
            return false;
        }
        Vehiculo other = (Vehiculo) object;
        if ((this.iDVehiculo == null && other.iDVehiculo != null) || (this.iDVehiculo != null && !this.iDVehiculo.equals(other.iDVehiculo))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "com.upec.model.Vehiculo[ iDVehiculo=" + iDVehiculo + " ]";
    }
    
}