package com.ferreteria.empresa;

import com.ferreteria.datos.Conexion;
import java.sql.ResultSet;

public class Empresa {

    private int idEmpresa;
    private String nombre;
    private String slogan;
    private String ruc;
    private String correo;
    private String correoAlt;
    private String telefono1;
    private String telefono2;
    private String direccion;
    private String ciudad;
    private String sitioWeb;
    private String logoUrl;
    private String descripcion;
    private String facebook;
    private String instagram;

    private Conexion con;

    // ============================================================
    //  CONSTRUCTOR: CARGA AUTOMÁTICAMENTE LOS DATOS DE LA EMPRESA
    // ============================================================
    public Empresa() {
        con = new Conexion();
        cargarDatosEmpresa();
    }

    private void cargarDatosEmpresa() {
        try {
            String sql = "SELECT * FROM tb_empresa ORDER BY id_empresa LIMIT 1";
            ResultSet rs = con.ConsultaSeguro(sql);

            if (rs != null && rs.next()) {

                this.idEmpresa   = rs.getInt("id_empresa");
                this.nombre      = rs.getString("nombre");
                this.slogan      = rs.getString("slogan");
                this.ruc         = rs.getString("ruc");
                this.correo      = rs.getString("correo");
                this.correoAlt   = rs.getString("correo_alt");
                this.telefono1   = rs.getString("telefono1");
                this.telefono2   = rs.getString("telefono2");
                this.direccion   = rs.getString("direccion");
                this.ciudad      = rs.getString("ciudad");
                this.sitioWeb    = rs.getString("sitio_web");
                this.logoUrl     = rs.getString("logo_url");
                this.descripcion = rs.getString("descripcion");
                this.facebook    = rs.getString("facebook");
                this.instagram   = rs.getString("instagram");

                System.out.println("✔ Datos de empresa cargados correctamente");

            } else {
                System.out.println("❌ No se encontraron datos en tb_empresa");
            }

        } catch (Exception e) {
            System.out.println("❌ Error cargando datos de empresa: " + e.getMessage());
        }
    }

    // ============================================================
    //  MÉTODO GENERAL PARA ACTUALIZAR UN CAMPO EN LA BASE DE DATOS
    // ============================================================
    private void actualizarCampo(String campo, Object valor) {
        try {
            String sql = "UPDATE tb_empresa SET " + campo + " = ? WHERE id_empresa = ?";
            con.EjecutarSeguro(sql, valor, this.idEmpresa);
            System.out.println("✔ Campo actualizado: " + campo);
        } catch (Exception e) {
            System.out.println("❌ Error actualizando campo: " + campo + " -> " + e.getMessage());
        }
    }

    // ============================================================
    //  GETTERS Y SETTERS (CON ACTUALIZACIÓN AUTOMÁTICA)
    // ============================================================

    public int getIdEmpresa() { return idEmpresa; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) {
        this.nombre = nombre;
        actualizarCampo("nombre", nombre);
    }

    public String getSlogan() { return slogan; }
    public void setSlogan(String slogan) {
        this.slogan = slogan;
        actualizarCampo("slogan", slogan);
    }

    public String getRuc() { return ruc; }
    public void setRuc(String ruc) {
        this.ruc = ruc;
        actualizarCampo("ruc", ruc);
    }

    public String getCorreo() { return correo; }
    public void setCorreo(String correo) {
        this.correo = correo;
        actualizarCampo("correo", correo);
    }

    public String getCorreoAlt() { return correoAlt; }
    public void setCorreoAlt(String correoAlt) {
        this.correoAlt = correoAlt;
        actualizarCampo("correo_alt", correoAlt);
    }

    public String getTelefono1() { return telefono1; }
    public void setTelefono1(String telefono1) {
        this.telefono1 = telefono1;
        actualizarCampo("telefono1", telefono1);
    }

    public String getTelefono2() { return telefono2; }
    public void setTelefono2(String telefono2) {
        this.telefono2 = telefono2;
        actualizarCampo("telefono2", telefono2);
    }

    public String getDireccion() { return direccion; }
    public void setDireccion(String direccion) {
        this.direccion = direccion;
        actualizarCampo("direccion", direccion);
    }

    public String getCiudad() { return ciudad; }
    public void setCiudad(String ciudad) {
        this.ciudad = ciudad;
        actualizarCampo("ciudad", ciudad);
    }

    public String getSitioWeb() { return sitioWeb; }
    public void setSitioWeb(String sitioWeb) {
        this.sitioWeb = sitioWeb;
        actualizarCampo("sitio_web", sitioWeb);
    }

    public String getLogoUrl() { return logoUrl; }
    public void setLogoUrl(String logoUrl) {
        this.logoUrl = logoUrl;
        actualizarCampo("logo_url", logoUrl);
    }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
        actualizarCampo("descripcion", descripcion);
    }

    public String getFacebook() { return facebook; }
    public void setFacebook(String facebook) {
        this.facebook = facebook;
        actualizarCampo("facebook", facebook);
    }

    public String getInstagram() { return instagram; }
    public void setInstagram(String instagram) {
        this.instagram = instagram;
        actualizarCampo("instagram", instagram);
    }
}
