package com.ferreteria.admin;

import com.ferreteria.datos.Conexion;
import java.sql.*;
import java.util.*;

public class Producto {

    private int id;
    private String nombre;
    private String codigo;
    private int stock;
    private double precioVenta;
    private String marca;
    private String unidad;
    private String descripcion;

    // ─────────────────────────────
    // GETTERS
    // ─────────────────────────────
    public int getId() { return id; }
    public String getNombre() { return nombre; }
    public String getCodigo() { return codigo; }
    public int getStock() { return stock; }
    public double getPrecioVenta() { return precioVenta; }
    public String getMarca() { return marca; }
    public String getUnidad() { return unidad; }
    public String getDescripcion() { return descripcion; }


    // ─────────────────────────────
    // LISTAR PRODUCTOS (PARA SELECT)
    // ─────────────────────────────
    public static List<Producto> listar() {
        List<Producto> lista = new ArrayList<>();

        String sql = """
            SELECT id_producto, codigo_barra, nombre, 
                   cantidad AS stock, precio_venta,
                   marca, unidad, descripcion
            FROM tb_producto
            ORDER BY nombre
        """;

        try (Conexion cx = new Conexion();
             PreparedStatement ps = cx.getConexion().prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Producto p = new Producto();

                p.id = rs.getInt("id_producto");
                p.codigo = rs.getString("codigo_barra");
                p.nombre = rs.getString("nombre");
                p.stock = rs.getInt("stock");
                p.precioVenta = rs.getDouble("precio_venta");
                p.marca = rs.getString("marca");
                p.unidad = rs.getString("unidad");
                p.descripcion = rs.getString("descripcion");

                lista.add(p);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return lista;
    }


    // ─────────────────────────────
    // BUSCAR PRODUCTO POR ID
    // ─────────────────────────────
    public static Producto obtener(int idProducto) {

        String sql = """
            SELECT id_producto, codigo_barra, nombre,
                   cantidad AS stock, precio_venta,
                   marca, unidad, descripcion
            FROM tb_producto
            WHERE id_producto = ?
        """;

        Producto p = null;

        try (Conexion cx = new Conexion();
             PreparedStatement ps = cx.getConexion().prepareStatement(sql)) {

            ps.setInt(1, idProducto);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                p = new Producto();
                p.id = rs.getInt("id_producto");
                p.codigo = rs.getString("codigo_barra");
                p.nombre = rs.getString("nombre");
                p.stock = rs.getInt("stock");
                p.precioVenta = rs.getDouble("precio_venta");
                p.marca = rs.getString("marca");
                p.unidad = rs.getString("unidad");
                p.descripcion = rs.getString("descripcion");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return p;
    }


    // ─────────────────────────────
    // ACTUALIZAR STOCK
    // ─────────────────────────────
    public static void aumentarStock(int idProducto, int cantidad) {

        String sql = "UPDATE tb_producto SET cantidad = cantidad + ? WHERE id_producto = ?";

        try (Conexion cx = new Conexion();
             PreparedStatement ps = cx.getConexion().prepareStatement(sql)) {

            ps.setInt(1, cantidad);
            ps.setInt(2, idProducto);
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    // ─────────────────────────────
    // OBTENER PRECIO DE COMPRA POR PROVEEDOR (tb_producto_proveedor)
    // ─────────────────────────────
    public static Double obtenerPrecioProveedor(int idProducto, int idProveedor) {

        String sql = """
            SELECT precio_compra FROM tb_producto_proveedor
            WHERE id_producto = ? AND id_proveedor = ?
        """;

        try (Conexion cx = new Conexion();
             PreparedStatement ps = cx.getConexion().prepareStatement(sql)) {

            ps.setInt(1, idProducto);
            ps.setInt(2, idProveedor);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getDouble("precio_compra");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null; // no existe relación
    }
    public static List<Producto> listarSoloActivosConStock() {
        List<Producto> lista = new ArrayList<>();

        String sql = """
            SELECT id_producto, codigo_barra, nombre,
                   cantidad AS stock, precio_venta,
                   marca, unidad, descripcion
            FROM tb_producto
            WHERE activo = true
            AND cantidad > 0
            ORDER BY nombre
        """;

        try (Conexion cx = new Conexion();
             PreparedStatement ps = cx.getConexion().prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Producto p = new Producto();

                p.id = rs.getInt("id_producto");
                p.codigo = rs.getString("codigo_barra");
                p.nombre = rs.getString("nombre");
                p.stock = rs.getInt("stock");
                p.precioVenta = rs.getDouble("precio_venta");
                p.marca = rs.getString("marca");
                p.unidad = rs.getString("unidad");
                p.descripcion = rs.getString("descripcion");

                lista.add(p);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return lista;
    }

}
