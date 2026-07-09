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
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.NamedQueries;
import jakarta.persistence.NamedQuery;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import jakarta.xml.bind.annotation.XmlRootElement;
import java.io.Serializable;
import java.math.BigDecimal;

/**
 *
 * @author ACER NITRO V15
 */
@Entity
@Table(name = "detalle_factura")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "DetalleFactura.findAll", query = "SELECT d FROM DetalleFactura d"),
    @NamedQuery(name = "DetalleFactura.findByIDDetalleFactura", query = "SELECT d FROM DetalleFactura d WHERE d.iDDetalleFactura = :iDDetalleFactura"),
    @NamedQuery(name = "DetalleFactura.findByDescripcion", query = "SELECT d FROM DetalleFactura d WHERE d.descripcion = :descripcion"),
    @NamedQuery(name = "DetalleFactura.findByCantidad", query = "SELECT d FROM DetalleFactura d WHERE d.cantidad = :cantidad"),
    @NamedQuery(name = "DetalleFactura.findByPrecioUnitario", query = "SELECT d FROM DetalleFactura d WHERE d.precioUnitario = :precioUnitario"),
    @NamedQuery(name = "DetalleFactura.findBySubtotal", query = "SELECT d FROM DetalleFactura d WHERE d.subtotal = :subtotal")})
public class DetalleFactura implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "ID_Detalle_Factura")
    private Integer iDDetalleFactura;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 255)
    @Column(name = "Descripcion")
    private String descripcion;
    @Column(name = "Cantidad")
    private Integer cantidad;
    // @Max(value=?)  @Min(value=?)//if you know range of your decimal fields consider using these annotations to enforce field validation
    @Column(name = "Precio_Unitario")
    private BigDecimal precioUnitario;
    @Column(name = "Subtotal")
    private BigDecimal subtotal;
    @JoinColumn(name = "ID_Factura", referencedColumnName = "ID_Factura")
    @ManyToOne(optional = false)
    private Factura iDFactura;
    @JoinColumn(name = "ID_Repuesto", referencedColumnName = "ID_Repuesto")
    @ManyToOne
    private Repuesto iDRepuesto;
    @JoinColumn(name = "ID_Servicio", referencedColumnName = "ID_Servicio")
    @ManyToOne
    private Servicio iDServicio;

    public DetalleFactura() {
    }

    public DetalleFactura(Integer iDDetalleFactura) {
        this.iDDetalleFactura = iDDetalleFactura;
    }

    public DetalleFactura(Integer iDDetalleFactura, String descripcion) {
        this.iDDetalleFactura = iDDetalleFactura;
        this.descripcion = descripcion;
    }

    public Integer getIDDetalleFactura() {
        return iDDetalleFactura;
    }

    public void setIDDetalleFactura(Integer iDDetalleFactura) {
        this.iDDetalleFactura = iDDetalleFactura;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public Integer getCantidad() {
        return cantidad;
    }

    public void setCantidad(Integer cantidad) {
        this.cantidad = cantidad;
    }

    public BigDecimal getPrecioUnitario() {
        return precioUnitario;
    }

    public void setPrecioUnitario(BigDecimal precioUnitario) {
        this.precioUnitario = precioUnitario;
    }

    public BigDecimal getSubtotal() {
        return subtotal;
    }

    public void setSubtotal(BigDecimal subtotal) {
        this.subtotal = subtotal;
    }

    public Factura getIDFactura() {
        return iDFactura;
    }

    public void setIDFactura(Factura iDFactura) {
        this.iDFactura = iDFactura;
    }

    public Repuesto getIDRepuesto() {
        return iDRepuesto;
    }

    public void setIDRepuesto(Repuesto iDRepuesto) {
        this.iDRepuesto = iDRepuesto;
    }

    public Servicio getIDServicio() {
        return iDServicio;
    }

    public void setIDServicio(Servicio iDServicio) {
        this.iDServicio = iDServicio;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (iDDetalleFactura != null ? iDDetalleFactura.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof DetalleFactura)) {
            return false;
        }
        DetalleFactura other = (DetalleFactura) object;
        if ((this.iDDetalleFactura == null && other.iDDetalleFactura != null) || (this.iDDetalleFactura != null && !this.iDDetalleFactura.equals(other.iDDetalleFactura))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "com.upec.model.DetalleFactura[ iDDetalleFactura=" + iDDetalleFactura + " ]";
    }
    
}
