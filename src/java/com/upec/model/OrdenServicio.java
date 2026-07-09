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
import jakarta.persistence.Temporal;
import jakarta.persistence.TemporalType;
import jakarta.validation.constraints.Size;
import jakarta.xml.bind.annotation.XmlRootElement;
import jakarta.xml.bind.annotation.XmlTransient;
import java.io.Serializable;
import java.util.Date;
import java.util.List;

/**
 *
 * @author ACER NITRO V15
 */
@Entity
@Table(name = "orden_servicio")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "OrdenServicio.findAll", query = "SELECT o FROM OrdenServicio o"),
    @NamedQuery(name = "OrdenServicio.findByIDOrdenServicio", query = "SELECT o FROM OrdenServicio o WHERE o.iDOrdenServicio = :iDOrdenServicio"),
    @NamedQuery(name = "OrdenServicio.findByFechaEntrada", query = "SELECT o FROM OrdenServicio o WHERE o.fechaEntrada = :fechaEntrada"),
    @NamedQuery(name = "OrdenServicio.findByFechaEstimadaSalida", query = "SELECT o FROM OrdenServicio o WHERE o.fechaEstimadaSalida = :fechaEstimadaSalida"),
    @NamedQuery(name = "OrdenServicio.findByFechaRealSalida", query = "SELECT o FROM OrdenServicio o WHERE o.fechaRealSalida = :fechaRealSalida")})
public class OrdenServicio implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "ID_Orden_Servicio")
    private Integer iDOrdenServicio;
    @Column(name = "Fecha_Entrada")
    @Temporal(TemporalType.TIMESTAMP)
    private Date fechaEntrada;
    @Column(name = "Fecha_Estimada_Salida")
    @Temporal(TemporalType.DATE)
    private Date fechaEstimadaSalida;
    @Column(name = "Fecha_Real_Salida")
    @Temporal(TemporalType.TIMESTAMP)
    private Date fechaRealSalida;
    @Lob
    @Size(max = 65535)
    @Column(name = "Problema_Reportado")
    private String problemaReportado;
    @Lob
    @Size(max = 65535)
    @Column(name = "Observaciones")
    private String observaciones;
    @JoinColumn(name = "ID_Empleado_Recepcion", referencedColumnName = "ID_Empleado")
    @ManyToOne(optional = false)
    private Empleado iDEmpleadoRecepcion;
    @JoinColumn(name = "ID_Estado_Trabajo", referencedColumnName = "ID_Estado_Trabajo")
    @ManyToOne(optional = false)
    private EstadoTrabajo iDEstadoTrabajo;
    @JoinColumn(name = "ID_Vehiculo", referencedColumnName = "ID_Vehiculo")
    @ManyToOne(optional = false)
    private Vehiculo iDVehiculo;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "iDOrdenServicio")
    private List<Factura> facturaList;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "iDOrdenServicio")
    private List<Diagnostico> diagnosticoList;

    public OrdenServicio() {
    }

    public OrdenServicio(Integer iDOrdenServicio) {
        this.iDOrdenServicio = iDOrdenServicio;
    }

    public Integer getIDOrdenServicio() {
        return iDOrdenServicio;
    }

    public void setIDOrdenServicio(Integer iDOrdenServicio) {
        this.iDOrdenServicio = iDOrdenServicio;
    }

    public Date getFechaEntrada() {
        return fechaEntrada;
    }

    public void setFechaEntrada(Date fechaEntrada) {
        this.fechaEntrada = fechaEntrada;
    }

    public Date getFechaEstimadaSalida() {
        return fechaEstimadaSalida;
    }

    public void setFechaEstimadaSalida(Date fechaEstimadaSalida) {
        this.fechaEstimadaSalida = fechaEstimadaSalida;
    }

    public Date getFechaRealSalida() {
        return fechaRealSalida;
    }

    public void setFechaRealSalida(Date fechaRealSalida) {
        this.fechaRealSalida = fechaRealSalida;
    }

    public String getProblemaReportado() {
        return problemaReportado;
    }

    public void setProblemaReportado(String problemaReportado) {
        this.problemaReportado = problemaReportado;
    }

    public String getObservaciones() {
        return observaciones;
    }

    public void setObservaciones(String observaciones) {
        this.observaciones = observaciones;
    }

    public Empleado getIDEmpleadoRecepcion() {
        return iDEmpleadoRecepcion;
    }

    public void setIDEmpleadoRecepcion(Empleado iDEmpleadoRecepcion) {
        this.iDEmpleadoRecepcion = iDEmpleadoRecepcion;
    }

    public EstadoTrabajo getIDEstadoTrabajo() {
        return iDEstadoTrabajo;
    }

    public void setIDEstadoTrabajo(EstadoTrabajo iDEstadoTrabajo) {
        this.iDEstadoTrabajo = iDEstadoTrabajo;
    }

    public Vehiculo getIDVehiculo() {
        return iDVehiculo;
    }

    public void setIDVehiculo(Vehiculo iDVehiculo) {
        this.iDVehiculo = iDVehiculo;
    }

    @XmlTransient
    public List<Factura> getFacturaList() {
        return facturaList;
    }

    public void setFacturaList(List<Factura> facturaList) {
        this.facturaList = facturaList;
    }

    @XmlTransient
    public List<Diagnostico> getDiagnosticoList() {
        return diagnosticoList;
    }

    public void setDiagnosticoList(List<Diagnostico> diagnosticoList) {
        this.diagnosticoList = diagnosticoList;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (iDOrdenServicio != null ? iDOrdenServicio.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof OrdenServicio)) {
            return false;
        }
        OrdenServicio other = (OrdenServicio) object;
        if ((this.iDOrdenServicio == null && other.iDOrdenServicio != null) || (this.iDOrdenServicio != null && !this.iDOrdenServicio.equals(other.iDOrdenServicio))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "com.upec.model.OrdenServicio[ iDOrdenServicio=" + iDOrdenServicio + " ]";
    }
    
}
