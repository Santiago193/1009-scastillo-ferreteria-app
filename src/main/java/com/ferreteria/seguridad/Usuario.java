package com.ferreteria.seguridad;

import java.sql.*;
import com.ferreteria.datos.Conexion;

public class Usuario {

    private int id_usuario;
    private String nombre;
    private String apellido;
    private String correo;
    private String contrasena;
    private int id_estadocivil;
    private int id_perfil;
    private boolean bloqueado;

    public Usuario() {}

    // ============================
    // GETTERS Y SETTERS
    // ============================

    public int getId_usuario() { return id_usuario; }
    public void setId_usuario(int id_usuario) { this.id_usuario = id_usuario; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getApellido() { return apellido; }
    public void setApellido(String apellido) { this.apellido = apellido; }

    public String getCorreo() { return correo; }
    public void setCorreo(String correo) { this.correo = correo; }

    public String getContrasena() { return contrasena; }
    public void setContrasena(String contrasena) { this.contrasena = contrasena; }

    public int getId_estadocivil() { return id_estadocivil; }
    public void setId_estadocivil(int id_estadocivil) { this.id_estadocivil = id_estadocivil; }

    public int getId_perfil() { return id_perfil; }
    public void setId_perfil(int id_perfil) { this.id_perfil = id_perfil; }

    public boolean isBloqueado() { return bloqueado; }
    public void setBloqueado(boolean bloqueado) { this.bloqueado = bloqueado; }

    // ============================
    // REGISTRO
    // ============================
    public String agregarAdmin() {
        String sql = "INSERT INTO tb_usuario (nombre, apellido, correo, contrasena, id_estadocivil, id_perfil) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection cn = new Conexion().getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, nombre);
            ps.setString(2, apellido);
            ps.setString(3, correo);
            ps.setString(4, contrasena);
            ps.setInt(5, id_estadocivil);
            ps.setInt(6, id_perfil);

            ps.executeUpdate();
            return "OK";

        } catch (Exception e) {
            return e.getMessage();
        }
    }

    // ============================
    // LOGIN
    // ============================
    public boolean verificarUsuario(String correo, String clave) {

        String sql = "SELECT * FROM tb_usuario WHERE correo = ? AND contrasena = ?";

        try (Connection cn = new Conexion().getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, correo);
            ps.setString(2, clave);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                this.bloqueado = rs.getBoolean("bloqueado");
                if (this.bloqueado) return false;

                this.id_usuario     = rs.getInt("id_usuario");
                this.nombre         = rs.getString("nombre");
                this.apellido       = rs.getString("apellido");
                this.correo         = rs.getString("correo");
                this.contrasena     = rs.getString("contrasena");
                this.id_estadocivil = rs.getInt("id_estadocivil");
                this.id_perfil      = rs.getInt("id_perfil");

                return true;
            }

        } catch (Exception e) {
            System.out.println("Error verificarUsuario: " + e.getMessage());
        }

        return false;
    }

    // ============================
    // LISTAR + FILTRO
    // ============================
    public static java.util.List<Usuario> buscar(String texto, int perfil) {

        java.util.List<Usuario> lista = new java.util.ArrayList<>();

        String sql = "SELECT * FROM tb_usuario WHERE "
                   + "(LOWER(nombre) LIKE LOWER(?) OR LOWER(apellido) LIKE LOWER(?)) ";

        if (perfil > 0) sql += " AND id_perfil = " + perfil;

        try (Connection cn = new Conexion().getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, "%" + texto + "%");
            ps.setString(2, "%" + texto + "%");

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Usuario u = new Usuario();
                u.id_usuario     = rs.getInt("id_usuario");
                u.nombre         = rs.getString("nombre");
                u.apellido       = rs.getString("apellido");
                u.correo         = rs.getString("correo");
                u.contrasena     = rs.getString("contrasena");
                u.id_perfil      = rs.getInt("id_perfil");
                u.bloqueado      = rs.getBoolean("bloqueado");
                lista.add(u);
            }

        } catch (Exception e) {
            System.out.println("Error buscar: " + e.getMessage());
        }

        return lista;
    }

    // ============================
    // OBTENER POR ID
    // ============================
    public static Usuario obtenerPorId(int id) {

        String sql = "SELECT * FROM tb_usuario WHERE id_usuario = ?";

        try (Connection cn = new Conexion().getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Usuario u = new Usuario();
                u.id_usuario     = rs.getInt("id_usuario");
                u.nombre         = rs.getString("nombre");
                u.apellido       = rs.getString("apellido");
                u.correo         = rs.getString("correo");
                u.contrasena     = rs.getString("contrasena");
                u.id_estadocivil = rs.getInt("id_estadocivil");
                u.id_perfil      = rs.getInt("id_perfil");
                u.bloqueado      = rs.getBoolean("bloqueado");
                return u;
            }

        } catch (Exception e) {
            System.out.println("Error obtenerPorId: " + e.getMessage());
        }

        return null;
    }

    // ============================
    // ACTUALIZAR USUARIO
    // ============================
    public String actualizar() {

        String sql = "UPDATE tb_usuario SET nombre=?, apellido=?, correo=?, contrasena=?, "
                   + "id_perfil=?, bloqueado=? WHERE id_usuario=?";

        try (Connection cn = new Conexion().getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, nombre);
            ps.setString(2, apellido);
            ps.setString(3, correo);
            ps.setString(4, contrasena);
            ps.setInt(5, id_perfil);
            ps.setBoolean(6, bloqueado);
            ps.setInt(7, id_usuario);

            ps.executeUpdate();
            return "OK";

        } catch (Exception e) {
            return e.getMessage();
        }
    }

    // ============================
    // ELIMINAR USUARIO
    // ============================
    public static boolean eliminar(int id) {

        String sql = "DELETE FROM tb_usuario WHERE id_usuario = ?";

        try (Connection cn = new Conexion().getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Error eliminar usuario: " + e.getMessage());
        }

        return false;
    }
}
