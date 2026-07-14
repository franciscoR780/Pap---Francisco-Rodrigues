<%-- 
    Document   : InserirSocios
    Created on : 11/11/2025, 11:24:04
    Author     : Aluno
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link href="style.css" rel="stylesheet" type="text/css">
        <%
        // verifica se houve um post
        if (request.getMethod().equals("POST")) {  %>
            <meta http-equiv="refresh" content="3;url=index.jsp">
        <% } %>
        <title>Inserção de Sócios</title>
    </head>
    <body>
        <h1>Inserir Sócios</h1>
        <%
        // verifica se houve um post
        if (request.getMethod().equals("POST")) {
            String telemovel = request.getParameter("telemovel");
            String id_utilizador = request.getParameter("id_utilizador");
            String data_nascimento = request.getParameter("data_nascimento");
            String cartao_cidadao = request.getParameter("cartao_cidadao");
            
            // JDBC parametros de conexão
            String url = "jdbc:mysql://localhost:3306/pap";
            String username = "root";
            String password = "";
            
            try { 
                // Load the MySQL JDBC driver
                Class.forName("com.mysql.cj.jdbc.Driver");
                // Establish the connection
                Connection conn = DriverManager.getConnection(url, username, password);
                
                // ✅ SQL SEM numero_socio (id_socio é auto-incrementado)
                String sql = "INSERT INTO t_socio (telemovel, id_utilizador, data_nascimento, cartao_de_cidadao) " +
                            "VALUES (?, ?, ?, ?)";
                PreparedStatement statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
                
                // Substitui os ? pelos parâmetros correspondentes
                statement.setString(1, telemovel);
                statement.setString(2, id_utilizador);
                statement.setString(3, data_nascimento);
                statement.setString(4, cartao_cidadao);
                
                // Executar a instrução SQL
                int rowsInserted = statement.executeUpdate();
                if (rowsInserted > 0) {
                    // 🎯 OBTER O ID GERADO
                    ResultSet generatedKeys = statement.getGeneratedKeys();
                    if (generatedKeys.next()) {
                        int idSocioGerado = generatedKeys.getInt(1);
                        out.println("<h2 style='color: green;'>✅ Registo inserido com sucesso!</h2>");
                        out.println("<p style='font-size: 18px;'><strong>ID do Sócio gerado:</strong> <span style='background: #FFD700; padding: 5px 15px; border-radius: 5px;'>" + idSocioGerado + "</span></p>");
                    }
                    generatedKeys.close();
                } else {
                    out.println("<h2 style='color: red;'>❌ Erro na inserção.</h2>");
                }
                
                // Close resources
                statement.close();
                conn.close();
                
            } catch (Exception e) {
                out.println("<h2 style='color: red;'>Ocorreu um erro: " + e.getMessage() + "</h2>");
            }
        }
        else
        {
        %>
            <div style="background: #f0f9ff; padding: 15px; border-radius: 8px; border: 2px solid #0ea5e9; margin-bottom: 20px;">
                <p style="margin: 0; color: #0c4a6e;">
                    ℹ️ <strong>Nota:</strong> O ID do sócio será gerado automaticamente pelo sistema.
                </p>
            </div>
            
            <form method="post" action="InserirSocios.jsp">
                <label>Utilizador: 
                    <select name="id_utilizador" required>
                        <option value="">Selecione...</option>
                        <%
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                Connection connEquipas = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");

                                Statement stmtEquipas = connEquipas.createStatement();
                                ResultSet rsEquipas = stmtEquipas.executeQuery("SELECT id_utilizador, primeiro_nome, ultimo_nome FROM t_utilizadores");

                                while (rsEquipas.next()) {
                        %>
                                    <option value="<%= rsEquipas.getInt("id_utilizador") %>"><%= rsEquipas.getString("primeiro_nome") %> <%= rsEquipas.getString("ultimo_nome") %></option>
                        <%          
                                }

                                rsEquipas.close();
                                stmtEquipas.close();
                                connEquipas.close();
                            } catch (Exception e) {
                                out.println("Erro ao carregar utilizador: " + e.getMessage());
                            }
                        %>
                    </select>
                </label><br/><br/>
                
                <label>Telemóvel: <input type="text" name="telemovel" size="20" 
                                        placeholder="Coloque o nº de telemóvel" required></label><br/><br/>
                <label>Cartão de Cidadão: <input type="text" name="cartao_cidadao" size="20" 
                                        placeholder="Nº do Cartão de Cidadão"></label><br/><br/>
                <label>Data Nascimento: <input type="date" name="data_nascimento"></label><br/><br/>                        
                <input type="submit" value="Inserir" class="bt">
            </form>
        <%
        }
        %>
        <a class="bt" href="admin.jsp" target="_self">Voltar ao menu</a>
    </body>
</html>