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
import jakarta.persistence.Temporal;
import jakarta.persistence.TemporalType;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import jakarta.xml.bind.annotation.XmlRootElement;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

/**
 *
 * @author ACER NITRO V15
 */
@Entity
@Table(name = "pago")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "Pago.findAll", query = "SELECT p FROM Pago p"),
    @NamedQuery(name = "Pago.findByIDPago", query = "SELECT p FROM Pago p WHERE p.iDPago = :iDPago"),
    @NamedQuery(name = "Pago.findByMontoPagado", query = "SELECT p FROM Pago p WHERE p.montoPagado = :montoPagado"),
    @NamedQuery(name = "Pago.findByFechaPago", query = "SELECT p FROM Pago p WHERE p.fechaPago = :fechaPago"),
    @NamedQuery(name = "Pago.findByReferenciaPago", query = "SELECT p FROM Pago p WHERE p.referenciaPago = :referenciaPago")})
public class Pago implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "ID_Pago")
    private Integer iDPago;
    // @Max(value=?)  @Min(value=?)//if you know range of your decimal fields consider using these annotations to enforce field validation
    @Basic(optional = false)
    @NotNull
    @Column(name = "Monto_Pagado")
    private BigDecimal montoPagado;
    @Column(name = "Fecha_Pago")
    @Temporal(TemporalType.TIMESTAMP)
    private Date fechaPago;
    @Size(max = 100)
    @Column(name = "Referencia_Pago")
    private String referenciaPago;
    @JoinColumn(name = "ID_Factura", referencedColumnName = "ID_Factura")
    @ManyToOne(optional = false)
    private Factura iDFactura;
    @JoinColumn(name = "ID_Forma_Pago", referencedColumnName = "ID_Forma_Pago")
    @ManyToOne(optional = false)
    private FormaPago iDFormaPago;

    public Pago() {
    }

    public Pago(Integer iDPago) {
        this.iDPago = iDPago;
    }

    public Pago(Integer iDPago, BigDecimal montoPagado) {
        this.iDPago = iDPago;
        this.montoPagado = montoPagado;
    }

    public Integer getIDPago() {
        return iDPago;
    }

    public void setIDPago(Integer iDPago) {
        this.iDPago = iDPago;
    }

    public BigDecimal getMontoPagado() {
        return montoPagado;
    }

    public void setMontoPagado(BigDecimal montoPagado) {
        this.montoPagado = montoPagado;
    }

    public Date getFechaPago() {
        return fechaPago;
    }

    public void setFechaPago(Date fechaPago) {
        this.fechaPago = fechaPago;
    }

    public String getReferenciaPago() {
        return referenciaPago;
    }

    public void setReferenciaPago(String referenciaPago) {
        this.referenciaPago = referenciaPago;
    }

    public Factura getIDFactura() {
        return iDFactura;
    }

    public void setIDFactura(Factura iDFactura) {
        this.iDFactura = iDFactura;
    }

    public FormaPago getIDFormaPago() {
        return iDFormaPago;
    }

    public void setIDFormaPago(FormaPago iDFormaPago) {
        this.iDFormaPago = iDFormaPago;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (iDPago != null ? iDPago.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Pago)) {
            return false;
        }
        Pago other = (Pago) object;
        if ((this.iDPago == null && other.iDPago != null) || (this.iDPago != null && !this.iDPago.equals(other.iDPago))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "com.upec.model.Pago[ iDPago=" + iDPago + " ]";
    }
    
}
