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
@Table(name = "forma_pago")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "FormaPago.findAll", query = "SELECT f FROM FormaPago f"),
    @NamedQuery(name = "FormaPago.findByIDFormaPago", query = "SELECT f FROM FormaPago f WHERE f.iDFormaPago = :iDFormaPago"),
    @NamedQuery(name = "FormaPago.findByNombreFormaPago", query = "SELECT f FROM FormaPago f WHERE f.nombreFormaPago = :nombreFormaPago")})
public class FormaPago implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "ID_Forma_Pago")
    private Integer iDFormaPago;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 50)
    @Column(name = "Nombre_Forma_Pago")
    private String nombreFormaPago;
    @Lob
    @Size(max = 65535)
    @Column(name = "Descripcion")
    private String descripcion;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "iDFormaPago")
    private List<Pago> pagoList;

    public FormaPago() {
    }

    public FormaPago(Integer iDFormaPago) {
        this.iDFormaPago = iDFormaPago;
    }

    public FormaPago(Integer iDFormaPago, String nombreFormaPago) {
        this.iDFormaPago = iDFormaPago;
        this.nombreFormaPago = nombreFormaPago;
    }

    public Integer getIDFormaPago() {
        return iDFormaPago;
    }

    public void setIDFormaPago(Integer iDFormaPago) {
        this.iDFormaPago = iDFormaPago;
    }

    public String getNombreFormaPago() {
        return nombreFormaPago;
    }

    public void setNombreFormaPago(String nombreFormaPago) {
        this.nombreFormaPago = nombreFormaPago;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    @XmlTransient
    public List<Pago> getPagoList() {
        return pagoList;
    }

    public void setPagoList(List<Pago> pagoList) {
        this.pagoList = pagoList;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (iDFormaPago != null ? iDFormaPago.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof FormaPago)) {
            return false;
        }
        FormaPago other = (FormaPago) object;
        if ((this.iDFormaPago == null && other.iDFormaPago != null) || (this.iDFormaPago != null && !this.iDFormaPago.equals(other.iDFormaPago))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "com.upec.model.FormaPago[ iDFormaPago=" + iDFormaPago + " ]";
    }
    
}
