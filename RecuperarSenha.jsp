<%-- 
    Document   : RecuperarSenha
    Created on : 28/12/2025
    Author     : Francisco
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Random" %>
<%@ page import="util.EmailUtil" %>
<%@ page import="util.PasswordUtil" %>
<%
    session.setMaxInactiveInterval(30 * 60); // 30 minutos

    String mensagem = "";
    String tipoMensagem = "";
    String passo = "email";
    String emailAtual = "";
    
    if (request.getMethod().equals("POST")) {
        String acao = request.getParameter("acao");
        
        // PASSO 1: Verificar email e enviar código
        if ("verificar_email".equals(acao)) {
            String email = request.getParameter("email");
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap", "root", "");
                
                // Verificar se email existe
                String sql = "SELECT id_utilizador, primeiro_nome FROM t_utilizadores WHERE email = ?";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setString(1, email);
                ResultSet rs = stmt.executeQuery();
                
                if (rs.next()) {
                    int idUtilizador = rs.getInt("id_utilizador");
                    String primeiroNome = rs.getString("primeiro_nome");
                    
                    // Gerar código de 6 dígitos
                    Random rand = new Random();
                    String codigo = String.format("%06d", rand.nextInt(1000000));
                    
                    // ⚡ NOVO: Fazer hash do código antes de guardar na BD
                    String codigoHash = PasswordUtil.hashPassword(codigo);
                    
                    // Guardar código HASH na BD
                    String sqlUpdate = "UPDATE t_utilizadores SET codigo_recuperacao = ?, data_codigo_recuperacao = NOW() WHERE id_utilizador = ?";
                    PreparedStatement stmtUpdate = conn.prepareStatement(sqlUpdate);
                    stmtUpdate.setString(1, codigoHash);
                    stmtUpdate.setInt(2, idUtilizador);
                    stmtUpdate.executeUpdate();
                    stmtUpdate.close();
                    
                    // ENVIAR EMAIL com o código em texto simples
                    boolean emailEnviado = EmailUtil.enviarEmailRecuperacao(email, primeiroNome, codigo);
                    
                    if (emailEnviado) {
                        mensagem = "Código de recuperação enviado para " + email;
                        tipoMensagem = "success";
                    } else {
                        mensagem = "Falhou o envio do email. Código: " + codigo;
                        tipoMensagem = "error";
                    }
                    
                    passo = "codigo";
                    emailAtual = email;
                } else {
                    mensagem = "Email não encontrado no sistema!";
                    tipoMensagem = "error";
                    passo = "email";
                }
                
                rs.close();
                stmt.close();
                conn.close();
            } catch (Exception e) {
                mensagem = "Erro: " + e.getMessage();
                tipoMensagem = "error";
                passo = "email";
            }
        }
        
        // PASSO 2: Validar código
        else if ("validar_codigo".equals(acao)) {
            String email = request.getParameter("email_hidden");
            String codigoInserido = request.getParameter("codigo");
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap", "root", "");
                
                // ⚡ NOVO: Buscar o hash do código na BD
                String sql = "SELECT id_utilizador, primeiro_nome, codigo_recuperacao " +
                            "FROM t_utilizadores " +
                            "WHERE email = ? " +
                            "AND data_codigo_recuperacao > DATE_SUB(NOW(), INTERVAL 30 MINUTE)";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setString(1, email);
                ResultSet rs = stmt.executeQuery();
                
                if (rs.next()) {
                    String codigoHash = rs.getString("codigo_recuperacao");
                    
                    // ⚡ NOVO: Verificar se o código inserido corresponde ao hash
                    if (PasswordUtil.checkPassword(codigoInserido, codigoHash)) {
                        mensagem = "Código válido! Define a tua nova senha.";
                        tipoMensagem = "success";
                        passo = "nova_senha";
                        emailAtual = email;
                    } else {
                        mensagem = "Código inválido!";
                        tipoMensagem = "error";
                        passo = "codigo";
                        emailAtual = email;
                    }
                } else {
                    mensagem = "Código expirado ou email inválido!";
                    tipoMensagem = "error";
                    passo = "codigo";
                    emailAtual = email;
                }
                
                rs.close();
                stmt.close();
                conn.close();
            } catch (Exception e) {
                mensagem = "Erro: " + e.getMessage();
                tipoMensagem = "error";
                passo = "codigo";
                emailAtual = email;
            }
        }
        
        // PASSO 3: Alterar senha
        else if ("alterar_senha".equals(acao)) {
            String email = request.getParameter("email_hidden");
            String novaSenha = request.getParameter("nova_senha");
            String confirmarSenha = request.getParameter("confirmar_senha");
            
            if (!novaSenha.equals(confirmarSenha)) {
                mensagem = "As senhas não coincidem!";
                tipoMensagem = "error";
                passo = "nova_senha";
                emailAtual = email;
            } else if (novaSenha.length() < 6) {
                mensagem = "A senha deve ter pelo menos 6 caracteres!";
                tipoMensagem = "error";
                passo = "nova_senha";
                emailAtual = email;
            } else {
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap", "root", "");
                    
                    // ⚡ NOVO: Fazer hash da nova senha antes de guardar
                    String senhaHash = PasswordUtil.hashPassword(novaSenha);
                    
                    // Atualizar senha HASH e limpar código
                    String sql = "UPDATE t_utilizadores SET palavra_passe = ?, codigo_recuperacao = NULL, data_codigo_recuperacao = NULL WHERE email = ?";
                    PreparedStatement stmt = conn.prepareStatement(sql);
                    stmt.setString(1, senhaHash);
                    stmt.setString(2, email);
                    
                    int rowsUpdated = stmt.executeUpdate();
                    
                    if (rowsUpdated > 0) {
                        mensagem = "Senha alterada com sucesso! Redirecionando para o login...";
                        tipoMensagem = "success";
                        response.setHeader("Refresh", "3;url=Login.jsp");
                    } else {
                        mensagem = "Erro ao alterar senha!";
                        tipoMensagem = "error";
                        passo = "nova_senha";
                        emailAtual = email;
                    }
                    
                    stmt.close();
                    conn.close();
                } catch (Exception e) {
                    mensagem = "Erro: " + e.getMessage();
                    tipoMensagem = "error";
                    passo = "nova_senha";
                    emailAtual = email;
                }
            }
        }
        
        // Reenviar código
        else if ("reenviar_codigo".equals(acao)) {
            String email = request.getParameter("email_hidden");
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap", "root", "");
                
                String sql = "SELECT id_utilizador, primeiro_nome FROM t_utilizadores WHERE email = ?";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setString(1, email);
                ResultSet rs = stmt.executeQuery();
                
                if (rs.next()) {
                    int idUtilizador = rs.getInt("id_utilizador");
                    String primeiroNome = rs.getString("primeiro_nome");
                    
                    // Gerar novo código
                    Random rand = new Random();
                    String novoCodigo = String.format("%06d", rand.nextInt(1000000));
                    
                    // ⚡ NOVO: Fazer hash do novo código
                    String novoCodigoHash = PasswordUtil.hashPassword(novoCodigo);
                    
                    // Atualizar código HASH
                    String updateSql = "UPDATE t_utilizadores SET codigo_recuperacao = ?, data_codigo_recuperacao = NOW() WHERE id_utilizador = ?";
                    PreparedStatement updateStmt = conn.prepareStatement(updateSql);
                    updateStmt.setString(1, novoCodigoHash);
                    updateStmt.setInt(2, idUtilizador);
                    updateStmt.executeUpdate();
                    updateStmt.close();
                    
                    // Enviar email com código em texto simples
                    boolean emailEnviado = EmailUtil.enviarEmailRecuperacao(email, primeiroNome, novoCodigo);
                    
                    if (emailEnviado) {
                        mensagem = "Novo código enviado para " + email;
                        tipoMensagem = "success";
                    } else {
                        mensagem = "Falhou o envio. Novo código: " + novoCodigo;
                        tipoMensagem = "error";
                    }
                    
                    passo = "codigo";
                    emailAtual = email;
                }
                
                rs.close();
                stmt.close();
                conn.close();
            } catch (Exception e) {
                mensagem = "Erro: " + e.getMessage();
                tipoMensagem = "error";
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SC Rio Tinto - Recuperar Senha</title>
    <link href="css/CssRecuperarSenha.css" rel="stylesheet" type="text/css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">
                <img src="images/Logo SCRT.jpg" alt="SC Rio Tinto">
            </div>
            <h1>Recuperar Senha</h1>
            <p class="subtitle">
                <% if (passo.equals("email")) { %>
                    Insere o teu email para recuperares a senha
                <% } else if (passo.equals("codigo")) { %>
                    Verifica o teu email e insere o código
                <% } else if (passo.equals("nova_senha")) { %>
                    Define a tua nova senha
                <% } %>
            </p>
        </div>

        <div class="progress-steps">
            <div class="step <%= passo.equals("email") ? "active" : "completed" %>">1</div>
            <div class="step <%= passo.equals("codigo") ? "active" : (passo.equals("nova_senha") ? "completed" : "") %>">2</div>
            <div class="step <%= passo.equals("nova_senha") ? "active" : "" %>">3</div>
        </div>

        <% if (!mensagem.isEmpty()) { %>
            <div class="message-box <%= tipoMensagem %>">
                <i class="fas fa-<%= tipoMensagem.equals("success") ? "check-circle" : "exclamation-circle" %>"></i>
                <%= mensagem %>
            </div>
        <% } %>

        <% if (passo.equals("email")) { %>
            <form method="post">
                <input type="hidden" name="acao" value="verificar_email">
                <div class="form-group">
                    <label for="email">Email *</label>
                    <input type="email" name="email" id="email" required placeholder="seu@email.com">
                </div>
                <button type="submit" class="btn-submit">
                    <i class="fas fa-paper-plane"></i> Enviar Código
                </button>
            </form>
        <% } %>

        <% if (passo.equals("codigo")) { %>
            <% if (!emailAtual.isEmpty()) { %>
                <div class="message-box info">
                    <i class="fas fa-envelope"></i>
                    Código enviado para: <%= emailAtual %>
                </div>
            <% } %>
            <form method="post">
                <input type="hidden" name="acao" value="validar_codigo">
                <input type="hidden" name="email_hidden" value="<%= emailAtual %>">
                <div class="form-group">
                    <label for="codigo">Código de Verificação *</label>
                    <input type="text" name="codigo" id="codigo" required 
                           maxlength="6" pattern="[0-9]{6}" 
                           class="codigo-input" placeholder="000000" autocomplete="off">
                </div>
                <button type="submit" class="btn-submit">
                    <i class="fas fa-check"></i> Validar Código
                </button>
            </form>

            <form method="post" style="margin-top: 1rem;">
                <input type="hidden" name="acao" value="reenviar_codigo">
                <input type="hidden" name="email_hidden" value="<%= emailAtual %>">
                <button type="submit" class="btn-submit btn-secondary">
                    <i class="fas fa-redo"></i> Reenviar Código
                </button>
            </form>
        <% } %>

        <% if (passo.equals("nova_senha")) { %>
            <div class="password-requirements">
                <strong>📋 Requisitos da senha:</strong>
                <ul>
                    <li>Mínimo de 6 caracteres</li>
                    <li>As senhas devem coincidir</li>
                </ul>
            </div>
            <form method="post">
                <input type="hidden" name="acao" value="alterar_senha">
                <input type="hidden" name="email_hidden" value="<%= emailAtual %>">
                <div class="form-group">
                    <label for="nova_senha">Nova Senha *</label>
                    <input type="password" name="nova_senha" id="nova_senha" required minlength="6">
                </div>
                <div class="form-group">
                    <label for="confirmar_senha">Confirmar Senha *</label>
                    <input type="password" name="confirmar_senha" id="confirmar_senha" required minlength="6">
                </div>
                <button type="submit" class="btn-submit">
                    <i class="fas fa-lock"></i> Alterar Senha
                </button>
            </form>
        <% } %>

        <div class="footer-link">
            <a href="Login.jsp">
                <i class="fas fa-arrow-left"></i> Voltar ao Login
            </a>
            <% if (!passo.equals("email")) { %>
                <br>
                <a href="RecuperarSenha.jsp" style="color: #ef4444;">
                    <i class="fas fa-times-circle"></i> Recomeçar
                </a>
            <% } %>
        </div>
    </div>

    <script>
        <% if (passo.equals("codigo")) { %>
            document.getElementById('codigo').focus();
        <% } %>

        <% if (passo.equals("nova_senha")) { %>
            const novaSenha = document.getElementById('nova_senha');
            const confirmarSenha = document.getElementById('confirmar_senha');
            
            confirmarSenha.addEventListener('input', function() {
                if (this.value !== novaSenha.value) {
                    this.setCustomValidity('As senhas não coincidem!');
                } else {
                    this.setCustomValidity('');
                }
            });
        <% } %>
    </script>
</body>
</html>