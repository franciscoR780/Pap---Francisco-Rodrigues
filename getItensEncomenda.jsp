<%--
    Document   : getItensEncomenda
    Created on : 26/10/2025, 13:37:59
    Author     : Francisco
--%>


<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    response.setContentType("application/json");
    
    String idEncomendaStr = request.getParameter("id");
    
    if (idEncomendaStr == null) {
        out.print("[]");
        return;
    }
    
    int idEncomenda = Integer.parseInt(idEncomendaStr);
    
    String url = "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC";
    String username = "root";
    String password = "";
    
    StringBuilder json = new StringBuilder("[");
    Connection conn = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, username, password);
        
        // ✅ Consulta corrigida com id_produto
        String sql = "SELECT ie.quantidade, ie.preco_unitario, ie.preco_total, p.nome_produto " +
                     "FROM t_itens_encomenda ie " +
                     "JOIN t_produtos p ON ie.id_produto = p.id_produto " +
                     "WHERE ie.id_encomenda = ?";
        
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setInt(1, idEncomenda);
        ResultSet rs = stmt.executeQuery();
        
        boolean first = true;
        while (rs.next()) {
            if (!first) {
                json.append(",");
            }
            
            json.append("{");
            json.append("\"quantidade\":").append(rs.getInt("quantidade")).append(",");
            json.append("\"nome\":\"").append(rs.getString("nome_produto").replace("\"", "\\\"")).append("\",");
            json.append("\"preco\":").append(rs.getDouble("preco_unitario")).append(",");
            json.append("\"preco_total\":").append(rs.getDouble("preco_total"));
            json.append("}");
            
            first = false;
        }
        
        rs.close();
        stmt.close();
        
    } catch (Exception e) {
        // Em caso de erro, retornar erro em JSON
        json = new StringBuilder("[");
        json.append("{\"erro\":\"").append(e.getMessage().replace("\"", "\\\"")).append("\"}");
        e.printStackTrace();
    } finally {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    json.append("]");
    out.print(json.toString());
%>