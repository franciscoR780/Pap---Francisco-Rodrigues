<%-- 
    Document   : InserirProdutos
    Created on : Dec 14, 2025, 4:02:51 PM
    Author     : Francisco
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <link href="style.css" rel="stylesheet" type="text/css">

    <%
        if (request.getMethod().equals("POST")) {
    %>
        <meta http-equiv="refresh" content="2;url=index.jsp">
    <%
        }
    %>

    <title>Inserção de Produtos</title>
</head>

<body>
<h1>Inserir Produtos</h1>

<%
    String url = "jdbc:mysql://localhost:3306/pap";
    String username = "root";
    String password = "";

    if (request.getMethod().equals("POST")) {

        String id_categoria = request.getParameter("id_categoria");
        String nome_produto = request.getParameter("nome_produto");
        String descricao = request.getParameter("descricao");
        String preco = request.getParameter("preco");
        String stock = request.getParameter("stock");
        String temporada = request.getParameter("temporada");
        String imagem_principal = request.getParameter("imagem_principal");

        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection conn = DriverManager.getConnection(url, username, password);

            String sql = "INSERT INTO t_produtos " +
                         "(id_categoria, nome_produto, descricao, preco, stock, temporada, imagem_principal) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?)";

            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, Integer.parseInt(id_categoria));
            stmt.setString(2, nome_produto);
            stmt.setString(3, descricao);
            stmt.setDouble(4, Double.parseDouble(preco));
            stmt.setInt(5, Integer.parseInt(stock));
            stmt.setString(6, temporada);
            stmt.setString(7, imagem_principal);

            int rows = stmt.executeUpdate();

            if (rows > 0) {
                out.println("<h2>Produto inserido com sucesso!</h2>");
            } else {
                out.println("<h2>Erro ao inserir produto.</h2>");
            }

            stmt.close();
            conn.close();

        } catch (Exception e) {
            out.println("<h3>Erro: " + e.getMessage() + "</h3>");
        }

    } else {
%>

<form method="post" action="InserirProdutos.jsp">

    <label>Categoria:
        <select name="id_categoria" required>
            <option value="">-- Selecione uma categoria --</option>
            <%
                try {
                    Class.forName("com.mysql.jdbc.Driver");
                    Connection conn = DriverManager.getConnection(url, username, password);

                    String sqlCat = "SELECT id_categoria, nome FROM t_categoria";
                    Statement st = conn.createStatement();
                    ResultSet rs = st.executeQuery(sqlCat);

                    while (rs.next()) {
            %>
                <option value="<%= rs.getInt("id_categoria") %>">
                    <%= rs.getString("nome") %>
                </option>
            <%
                    }

                    rs.close();
                    st.close();
                    conn.close();

                } catch (Exception e) {
                    out.println("<option>Erro ao carregar categorias</option>");
                }
            %>
        </select>
    </label>

    <br/><br/>

    <label>Nome do Produto:
        <input type="text" name="nome_produto" size="40" required>
    </label>

    <br/><br/>

    <label>Descrição:<br>
        <textarea name="descricao" rows="4" cols="40"></textarea>
    </label>

    <br/><br/>

    <label>Preço:
        <input type="number" step="0.01" name="preco" required>
    </label>

    <br/><br/>

    <label>Stock:
        <input type="number" name="stock" value="0" required>
    </label>

    <br/><br/>

    <label>Temporada:
        <input type="text" name="temporada">
    </label>

    <br/><br/>

    <label>Imagem Principal (URL):
        <input type="text" name="imagem_principal">
    </label>

    <br/><br/>

    <input type="submit" value="Inserir" class="bt">
</form>

<%
    }
%>

<br/>
<a class="bt" href="admin.jsp">Voltar ao menu</a>

</body>
</html>
