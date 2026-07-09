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
import jakarta.persistence.Lob;
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
import java.util.Date;

/**
 *
 * @author ACER NITRO V15
 */
@Entity
@Table(name = "diagnostico")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "Diagnostico.findAll", query = "SELECT d FROM Diagnostico d"),
    @NamedQuery(name = "Diagnostico.findByIDDiagnostico", query = "SELECT d FROM Diagnostico d WHERE d.iDDiagnostico = :iDDiagnostico"),
    @NamedQuery(name = "Diagnostico.findByFechaDiagnostico", query = "SELECT d FROM Diagnostico d WHERE d.fechaDiagnostico = :fechaDiagnostico")})
public class Diagnostico implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "ID_Diagnostico")
    private Integer iDDiagnostico;
    @Basic(optional = false)
    @NotNull
    @Lob
    @Size(min = 1, max = 65535)
    @Column(name = "Descripcion_Diagnostico")
    private String descripcionDiagnostico;
    @Column(name = "Fecha_Diagnostico")
    @Temporal(TemporalType.TIMESTAMP)
    private Date fechaDiagnostico;
    @Lob
    @Size(max = 65535)
    @Column(name = "Recomendaciones")
    private String recomendaciones;
    @JoinColumn(name = "ID_Empleado_Mecanico", referencedColumnName = "ID_Empleado")
    @ManyToOne(optional = false)
    private Empleado iDEmpleadoMecanico;
    @JoinColumn(name = "ID_Orden_Servicio", referencedColumnName = "ID_Orden_Servicio")
    @ManyToOne(optional = false)
    private OrdenServicio iDOrdenServicio;

    public Diagnostico() {
    }

    public Diagnostico(Integer iDDiagnostico) {
        this.iDDiagnostico = iDDiagnostico;
    }

    public Diagnostico(Integer iDDiagnostico, String descripcionDiagnostico) {
        this.iDDiagnostico = iDDiagnostico;
        this.descripcionDiagnostico = descripcionDiagnostico;
    }

    public Integer getIDDiagnostico() {
        return iDDiagnostico;
    }

    public void setIDDiagnostico(Integer iDDiagnostico) {
        this.iDDiagnostico = iDDiagnostico;
    }

    public String getDescripcionDiagnostico() {
        return descripcionDiagnostico;
    }

    public void setDescripcionDiagnostico(String descripcionDiagnostico) {
        this.descripcionDiagnostico = descripcionDiagnostico;
    }

    public Date getFechaDiagnostico() {
        return fechaDiagnostico;
    }

    public void setFechaDiagnostico(Date fechaDiagnostico) {
        this.fechaDiagnostico = fechaDiagnostico;
    }

    public String getRecomendaciones() {
        return recomendaciones;
    }

    public void setRecomendaciones(String recomendaciones) {
        this.recomendaciones = recomendaciones;
    }

    public Empleado getIDEmpleadoMecanico() {
        return iDEmpleadoMecanico;
    }

    public void setIDEmpleadoMecanico(Empleado iDEmpleadoMecanico) {
        this.iDEmpleadoMecanico = iDEmpleadoMecanico;
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
        hash += (iDDiagnostico != null ? iDDiagnostico.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Diagnostico)) {
            return false;
        }
        Diagnostico other = (Diagnostico) object;
        if ((this.iDDiagnostico == null && other.iDDiagnostico != null) || (this.iDDiagnostico != null && !this.iDDiagnostico.equals(other.iDDiagnostico))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "com.upec.model.Diagnostico[ iDDiagnostico=" + iDDiagnostico + " ]";
    }
    
}