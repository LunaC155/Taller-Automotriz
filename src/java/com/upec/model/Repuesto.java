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
@Table(name = "repuesto")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "Repuesto.findAll", query = "SELECT r FROM Repuesto r"),
    @NamedQuery(name = "Repuesto.findByIDRepuesto", query = "SELECT r FROM Repuesto r WHERE r.iDRepuesto = :iDRepuesto"),
    @NamedQuery(name = "Repuesto.findByNombreRepuesto", query = "SELECT r FROM Repuesto r WHERE r.nombreRepuesto = :nombreRepuesto"),
    @NamedQuery(name = "Repuesto.findByPrecioCompra", query = "SELECT r FROM Repuesto r WHERE r.precioCompra = :precioCompra"),
    @NamedQuery(name = "Repuesto.findByPrecioVenta", query = "SELECT r FROM Repuesto r WHERE r.precioVenta = :precioVenta"),
    @NamedQuery(name = "Repuesto.findByStock", query = "SELECT r FROM Repuesto r WHERE r.stock = :stock"),
    @NamedQuery(name = "Repuesto.findByStockMinimo", query = "SELECT r FROM Repuesto r WHERE r.stockMinimo = :stockMinimo"),
    @NamedQuery(name = "Repuesto.findByEstado", query = "SELECT r FROM Repuesto r WHERE r.estado = :estado")})
public class Repuesto implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "ID_Repuesto")
    private Integer iDRepuesto;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 100)
    @Column(name = "Nombre_Repuesto")
    private String nombreRepuesto;
    @Lob
    @Size(max = 65535)
    @Column(name = "Descripcion")
    private String descripcion;
    // @Max(value=?)  @Min(value=?)//if you know range of your decimal fields consider using these annotations to enforce field validation
    @Column(name = "Precio_Compra")
    private BigDecimal precioCompra;
    @Column(name = "Precio_Venta")
    private BigDecimal precioVenta;
    @Column(name = "Stock")
    private Integer stock;
    @Column(name = "Stock_Minimo")
    private Integer stockMinimo;
    @Column(name = "Estado")
    private Boolean estado;
    @OneToMany(mappedBy = "iDRepuesto")
    private List<DetalleFactura> detalleFacturaList;

    public Repuesto() {
    }

    public Repuesto(Integer iDRepuesto) {
        this.iDRepuesto = iDRepuesto;
    }

    public Repuesto(Integer iDRepuesto, String nombreRepuesto) {
        this.iDRepuesto = iDRepuesto;
        this.nombreRepuesto = nombreRepuesto;
    }

    public Integer getIDRepuesto() {
        return iDRepuesto;
    }

    public void setIDRepuesto(Integer iDRepuesto) {
        this.iDRepuesto = iDRepuesto;
    }

    public String getNombreRepuesto() {
        return nombreRepuesto;
    }

    public void setNombreRepuesto(String nombreRepuesto) {
        this.nombreRepuesto = nombreRepuesto;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public BigDecimal getPrecioCompra() {
        return precioCompra;
    }

    public void setPrecioCompra(BigDecimal precioCompra) {
        this.precioCompra = precioCompra;
    }

    public BigDecimal getPrecioVenta() {
        return precioVenta;
    }

    public void setPrecioVenta(BigDecimal precioVenta) {
        this.precioVenta = precioVenta;
    }

    public Integer getStock() {
        return stock;
    }

    public void setStock(Integer stock) {
        this.stock = stock;
    }

    public Integer getStockMinimo() {
        return stockMinimo;
    }

    public void setStockMinimo(Integer stockMinimo) {
        this.stockMinimo = stockMinimo;
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
        hash += (iDRepuesto != null ? iDRepuesto.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Repuesto)) {
            return false;
        }
        Repuesto other = (Repuesto) object;
        if ((this.iDRepuesto == null && other.iDRepuesto != null) || (this.iDRepuesto != null && !this.iDRepuesto.equals(other.iDRepuesto))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "com.upec.model.Repuesto[ iDRepuesto=" + iDRepuesto + " ]";
    }
    
}
