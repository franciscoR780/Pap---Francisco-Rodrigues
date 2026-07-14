<%--
    Document   : login_admin
    Created on : 09/12/2025, 09:54:12
    Author     : Francisco
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="util.PasswordUtil" %>
<%
    // VERIFICAR SE JÁ ESTÁ LOGADO COMO ADMIN NO SITE PRINCIPAL
    Boolean adminVerificadoSite = (Boolean) session.getAttribute("admin_verificado_site");
    Boolean isAdminSite = (Boolean) session.getAttribute("is_admin");
    Integer idUtilizadorSite = (Integer) session.getAttribute("id_utilizador");
    
    // Se já está verificado como admin no site, vai direto para o painel
    if (adminVerificadoSite != null && adminVerificadoSite && isAdminSite != null && isAdminSite) {
        response.sendRedirect("admin.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login Admin - SC Rio Tinto</title>
    <link href="css/CssLogin_Admin.css" rel="stylesheet" type="text/css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@100;200;300;400;500;600;700;800;900&display=swap" rel="stylesheet">
</head>
<body>
    <%
        String erro = "";
        
        if (request.getMethod().equals("POST")) {
            String email = request.getParameter("username");
            String password = request.getParameter("password");
            String captchaInput = request.getParameter("captcha");
            
            // VALIDAR CAPTCHA PRIMEIRO
            String captchaCode = (String) session.getAttribute("captcha");
            
            if (captchaCode == null || !captchaCode.equalsIgnoreCase(captchaInput)) {
                erro = "CAPTCHA inválido! Tente novamente.";
            } else if (email != null && password != null && !email.isEmpty() && !password.isEmpty()) {
                // Remover CAPTCHA da sessão após validação
                session.removeAttribute("captcha");
                
                String url = "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC";
                String dbUsername = "root";
                String dbPassword = "";
                
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection(url, dbUsername, dbPassword);
                    
                    // ⚡ NOVO: Verificar se o utilizador existe e é admin (buscar apenas pelo email)
                    String sql = "SELECT * FROM t_utilizadores WHERE email = ? AND tipo_utilizador = 'admin'";
                    PreparedStatement stmt = conn.prepareStatement(sql);
                    stmt.setString(1, email);
                    
                    ResultSet rs = stmt.executeQuery();
                    
                    if (rs.next()) {
                        // ⚡ NOVO: Buscar o hash da password
                        String senhaHash = rs.getString("palavra_passe");
                        
                        // ⚡ NOVO: Verificar se a password inserida corresponde ao hash
                        if (PasswordUtil.checkPassword(password, senhaHash)) {
                            // Login com sucesso - criar sessão do PAINEL ADMIN
                            session.setAttribute("admin_logado", true);
                            session.setAttribute("admin_username", rs.getString("primeiro_nome") + " " + rs.getString("ultimo_nome"));
                            session.setAttribute("admin_id", rs.getInt("id_utilizador"));
                            session.setAttribute("admin_email", rs.getString("email"));
                            
                            // IMPORTANTE: Também criar as flags do site principal para manter consistência
                            session.setAttribute("id_utilizador", rs.getInt("id_utilizador"));
                            session.setAttribute("primeiro_nome", rs.getString("primeiro_nome"));
                            session.setAttribute("ultimo_nome", rs.getString("ultimo_nome"));
                            session.setAttribute("email", rs.getString("email"));
                            session.setAttribute("is_admin", true);
                            session.setAttribute("admin_verificado_site", true);
                            
                            rs.close();
                            stmt.close();
                            conn.close();
                            
                            response.sendRedirect("admin.jsp");
                            return;
                        } else {
                            erro = "Email ou senha incorretos!";
                        }
                    } else {
                        erro = "Email, senha incorretos ou não tem permissão de administrador!";
                    }
                    
                    rs.close();
                    stmt.close();
                    conn.close();
                    
                } catch (Exception e) {
                    erro = "Erro ao conectar à base de dados: " + e.getMessage();
                }
            } else {
                erro = "Por favor, preencha todos os campos!";
            }
        }
    %>

    <div class="login-container">
        <div class="login-header">
            <div class="logo">
                <img src="images/logo login/Logo SCRT.png" alt="SC Rio Tinto Logo">
            </div>
            <h1>SC Rio Tinto</h1>
            <p>Painel de Administração</p>
        </div>

        <div class="login-body">
            <% if (!erro.isEmpty()) { %>
                <div class="error-message">
                    <i class="fas fa-exclamation-circle"></i>
                    <%= erro %>
                </div>
            <% } %>

            <form method="post" action="login_admin.jsp">
                <div class="form-group">
                    <label for="username">Email</label>
                    <div class="input-wrapper">
                        <i class="fas fa-envelope"></i>
                        <input 
                            type="email" 
                            id="username" 
                            name="username" 
                            class="form-control" 
                            placeholder="Digite o seu email"
                            required
                            autofocus
                        >
                    </div>
                </div>

                <div class="form-group">
                    <label for="password">Senha</label>
                    <div class="input-wrapper">
                        <i class="fas fa-lock"></i>
                        <input 
                            type="password" 
                            id="password" 
                            name="password" 
                            class="form-control" 
                            placeholder="Digite a senha"
                            required
                        >
                    </div>
                </div>

                <div class="form-group">
                    <label>CAPTCHA</label>
                    <div class="captcha-container">
                        <img id="captchaImage" src="captcha" alt="CAPTCHA" class="captcha-image">
                        <button type="button" class="refresh-btn" onclick="refreshCaptcha()" title="Gerar novo código">
                            <i class="fas fa-sync-alt"></i>
                        </button>
                    </div>
                </div>

                <div class="form-group">
                    <label for="captcha">Digite o código</label>
                    <input 
                        type="text" 
                        id="captcha" 
                        name="captcha" 
                        class="form-control" 
                        placeholder="Código CAPTCHA"
                        required
                        autocomplete="off"
                        maxlength="6"
                    >
                </div>

                <button type="submit" class="btn-login">
                    <i class="fas fa-sign-in-alt"></i> Entrar
                </button>
            </form>
        </div>
    </div>
    
    <script>
        function refreshCaptcha() {
            document.getElementById('captchaImage').src = 'captcha?' + new Date().getTime();
        }
    </script>
</body>
</html>