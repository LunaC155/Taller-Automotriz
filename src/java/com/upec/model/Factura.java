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
import jakarta.persistence.Temporal;
import jakarta.persistence.TemporalType;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import jakarta.xml.bind.annotation.XmlRootElement;
import jakarta.xml.bind.annotation.XmlTransient;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

/**
 *
 * @author ACER NITRO V15
 */
@Entity
@Table(name = "factura")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "Factura.findAll", query = "SELECT f FROM Factura f"),
    @NamedQuery(name = "Factura.findByIDFactura", query = "SELECT f FROM Factura f WHERE f.iDFactura = :iDFactura"),
    @NamedQuery(name = "Factura.findByNumeroFactura", query = "SELECT f FROM Factura f WHERE f.numeroFactura = :numeroFactura"),
    @NamedQuery(name = "Factura.findByFechaEmision", query = "SELECT f FROM Factura f WHERE f.fechaEmision = :fechaEmision"),
    @NamedQuery(name = "Factura.findBySubtotal", query = "SELECT f FROM Factura f WHERE f.subtotal = :subtotal"),
    @NamedQuery(name = "Factura.findByIva", query = "SELECT f FROM Factura f WHERE f.iva = :iva"),
    @NamedQuery(name = "Factura.findByTotal", query = "SELECT f FROM Factura f WHERE f.total = :total")})
public class Factura implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "ID_Factura")
    private Integer iDFactura;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 50)
    @Column(name = "Numero_Factura")
    private String numeroFactura;
    @Column(name = "Fecha_Emision")
    @Temporal(TemporalType.TIMESTAMP)
    private Date fechaEmision;
    // @Max(value=?)  @Min(value=?)//if you know range of your decimal fields consider using these annotations to enforce field validation
    @Column(name = "Subtotal")
    private BigDecimal subtotal;
    @Column(name = "IVA")
    private BigDecimal iva;
    @Column(name = "Total")
    private BigDecimal total;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "iDFactura")
    private List<DetalleFactura> detalleFacturaList;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "iDFactura")
    private List<Pago> pagoList;
    @JoinColumn(name = "ID_Estado_Factura", referencedColumnName = "ID_Estado_Factura")
    @ManyToOne(optional = false)
    private EstadoFactura iDEstadoFactura;
    @JoinColumn(name = "ID_Orden_Servicio", referencedColumnName = "ID_Orden_Servicio")
    @ManyToOne(optional = false)
    private OrdenServicio iDOrdenServicio;

    public Factura() {
    }

    public Factura(Integer iDFactura) {
        this.iDFactura = iDFactura;
    }

    public Factura(Integer iDFactura, String numeroFactura) {
        this.iDFactura = iDFactura;
        this.numeroFactura = numeroFactura;
    }

    public Integer getIDFactura() {
        return iDFactura;
    }

    public void setIDFactura(Integer iDFactura) {
        this.iDFactura = iDFactura;
    }

    public String getNumeroFactura() {
        return numeroFactura;
    }

    public void setNumeroFactura(String numeroFactura) {
        this.numeroFactura = numeroFactura;
    }

    public Date getFechaEmision() {
        return fechaEmision;
    }

    public void setFechaEmision(Date fechaEmision) {
        this.fechaEmision = fechaEmision;
    }

    public BigDecimal getSubtotal() {
        return subtotal;
    }

    public void setSubtotal(BigDecimal subtotal) {
        this.subtotal = subtotal;
    }

    public BigDecimal getIva() {
        return iva;
    }

    public void setIva(BigDecimal iva) {
        this.iva = iva;
    }

    public BigDecimal getTotal() {
        return total;
    }

    public void setTotal(BigDecimal total) {
        this.total = total;
    }

    @XmlTransient
    public List<DetalleFactura> getDetalleFacturaList() {
        return detalleFacturaList;
    }

    public void setDetalleFacturaList(List<DetalleFactura> detalleFacturaList) {
        this.detalleFacturaList = detalleFacturaList;
    }

    @XmlTransient
    public List<Pago> getPagoList() {
        return pagoList;
    }

    public void setPagoList(List<Pago> pagoList) {
        this.pagoList = pagoList;
    }

    public EstadoFactura getIDEstadoFactura() {
        return iDEstadoFactura;
    }

    public void setIDEstadoFactura(EstadoFactura iDEstadoFactura) {
        this.iDEstadoFactura = iDEstadoFactura;
    }

    public OrdenServicio getIDOrdenServicio() {
        return iDOrdenServicio;
    }

    public void setIDOrdenServicio(OrdenServicio iDOrdenServicio) {
        this.iDOrdenServicio = iDOrdenServicio;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (iDFactura != null ? iDFactura.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Factura)) {
            return false;
        }
        Factura other = (Factura) object;
        if ((this.iDFactura == null && other.iDFactura != null) || (this.iDFactura != null && !this.iDFactura.equals(other.iDFactura))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "com.upec.model.Factura[ iDFactura=" + iDFactura + " ]";
    }
    
}
