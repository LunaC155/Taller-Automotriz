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
@Table(name = "roles")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "Roles.findAll", query = "SELECT r FROM Roles r"),
    @NamedQuery(name = "Roles.findByIDRol", query = "SELECT r FROM Roles r WHERE r.iDRol = :iDRol"),
    @NamedQuery(name = "Roles.findByNombreRol", query = "SELECT r FROM Roles r WHERE r.nombreRol = :nombreRol"),
    @NamedQuery(name = "Roles.findByEstado", query = "SELECT r FROM Roles r WHERE r.estado = :estado")})
public class Roles implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "ID_Rol")
    private Integer iDRol;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 50)
    @Column(name = "Nombre_Rol")
    private String nombreRol;
    @Lob
    @Size(max = 65535)
    @Column(name = "Descripcion")
    private String descripcion;
    @Column(name = "Estado")
    private Boolean estado;
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "iDRol")
    private List<Usuarios> usuariosList;

    public Roles() {
    }

    public Roles(Integer iDRol) {
        this.iDRol = iDRol;
    }

    public Roles(Integer iDRol, String nombreRol) {
        this.iDRol = iDRol;
        this.nombreRol = nombreRol;
    }

    public Integer getIDRol() {
        return iDRol;
    }

    public void setIDRol(Integer iDRol) {
        this.iDRol = iDRol;
    }

    public String getNombreRol() {
        return nombreRol;
    }

    public void setNombreRol(String nombreRol) {
        this.nombreRol = nombreRol;
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
    public List<Usuarios> getUsuariosList() {
        return usuariosList;
    }

    public void setUsuariosList(List<Usuarios> usuariosList) {
        this.usuariosList = usuariosList;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (iDRol != null ? iDRol.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Roles)) {
            return false;
        }
        Roles other = (Roles) object;
        if ((this.iDRol == null && other.iDRol != null) || (this.iDRol != null && !this.iDRol.equals(other.iDRol))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "com.upec.model.Roles[ iDRol=" + iDRol + " ]";
    }

    public void setNivelAcceso(Integer nivelAcceso) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }
    
}