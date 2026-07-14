<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.mindrot.jbcrypt.BCrypt" %>
<%
    // Verificar se o utilizador está logado
    Integer idUtilizador = (Integer) session.getAttribute("id_utilizador");
    if (idUtilizador == null) {
        response.sendRedirect("index.htm");
        return;
    }
    
    String mensagem = "";
    String tipoMensagem = "";
    
    // Carregar dados do utilizador
    String primeiroNome = "";
    String ultimoNome = "";
    String email = "";
    String telefone = "";
    String dataNascimento = "";
    String tipoUtilizador = "";
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap", "root", "");
        
        String sql = "SELECT * FROM t_utilizadores WHERE id_utilizador = ?";
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setInt(1, idUtilizador);
        
        ResultSet rs = stmt.executeQuery();
        
        if (rs.next()) {
            primeiroNome = rs.getString("primeiro_nome");
            ultimoNome = rs.getString("ultimo_nome");
            email = rs.getString("email");
            telefone = rs.getString("telefone") != null ? rs.getString("telefone") : "";
            dataNascimento = rs.getString("data_nascimento") != null ? rs.getString("data_nascimento") : "";
            tipoUtilizador = rs.getString("tipo_utilizador");
        }
        
        rs.close();
        stmt.close();
        conn.close();
        
    } catch (Exception e) {
        mensagem = "Erro ao carregar dados: " + e.getMessage();
        tipoMensagem = "error";
    }
    
    // Processar atualização dos dados
    if (request.getMethod().equals("POST") && "atualizar_perfil".equals(request.getParameter("acao"))) {
        String novoPrimeiroNome = request.getParameter("primeiro_nome");
        String novoUltimoNome = request.getParameter("ultimo_nome");
        String novoEmail = request.getParameter("email");
        String novoTelefone = request.getParameter("telefone");
        String novaDataNascimento = request.getParameter("data_nascimento");
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap", "root", "");
            
            String sqlUpdate = "UPDATE t_utilizadores SET primeiro_nome = ?, ultimo_nome = ?, email = ?, telefone = ?, data_nascimento = ? WHERE id_utilizador = ?";
            PreparedStatement stmtUpdate = conn.prepareStatement(sqlUpdate);
            stmtUpdate.setString(1, novoPrimeiroNome);
            stmtUpdate.setString(2, novoUltimoNome);
            stmtUpdate.setString(3, novoEmail);
            stmtUpdate.setString(4, novoTelefone);
            stmtUpdate.setString(5, novaDataNascimento);
            stmtUpdate.setInt(6, idUtilizador);
            
            int rowsAffected = stmtUpdate.executeUpdate();
            
            if (rowsAffected > 0) {
                // Atualizar sessão
                session.setAttribute("primeiro_nome", novoPrimeiroNome);
                session.setAttribute("ultimo_nome", novoUltimoNome);
                session.setAttribute("email", novoEmail);
                
                // Atualizar variáveis locais
                primeiroNome = novoPrimeiroNome;
                ultimoNome = novoUltimoNome;
                email = novoEmail;
                telefone = novoTelefone;
                dataNascimento = novaDataNascimento;
                
                mensagem = "Perfil atualizado com sucesso!";
                tipoMensagem = "success";
            } else {
                mensagem = "Erro ao atualizar perfil!";
                tipoMensagem = "error";
            }
            
            stmtUpdate.close();
            conn.close();
            
        } catch (Exception e) {
            mensagem = "Erro: " + e.getMessage();
            tipoMensagem = "error";
        }
    }
    
    // Processar alteração de password
    if (request.getMethod().equals("POST") && "alterar_password".equals(request.getParameter("acao"))) {
        String passwordAtual = request.getParameter("password_atual");
        String novaPassword = request.getParameter("nova_password");
        String confirmarPassword = request.getParameter("confirmar_password");
        
        if (!novaPassword.equals(confirmarPassword)) {
            mensagem = "As passwords não coincidem!";
            tipoMensagem = "error";
        } else {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap", "root", "");
                
                // Buscar o hash BCrypt guardado na BD
                String sqlCheck = "SELECT palavra_passe FROM t_utilizadores WHERE id_utilizador = ?";
                PreparedStatement stmtCheck = conn.prepareStatement(sqlCheck);
                stmtCheck.setInt(1, idUtilizador);
                
                ResultSet rsCheck = stmtCheck.executeQuery();
                
                if (rsCheck.next()) {
                    String hashGuardado = rsCheck.getString("palavra_passe");
                    rsCheck.close();
                    stmtCheck.close();
                    
                    // Verificar password atual com BCrypt
                    boolean passwordCorreta = BCrypt.checkpw(passwordAtual, hashGuardado);
                    
                    if (passwordCorreta) {
                        // Encriptar nova password com BCrypt e guardar
                        String novaPasswordHash = BCrypt.hashpw(novaPassword, BCrypt.gensalt(12));
                        String sqlUpdatePass = "UPDATE t_utilizadores SET palavra_passe = ? WHERE id_utilizador = ?";
                        PreparedStatement stmtUpdatePass = conn.prepareStatement(sqlUpdatePass);
                        stmtUpdatePass.setString(1, novaPasswordHash);
                        stmtUpdatePass.setInt(2, idUtilizador);
                        
                        int rowsAffected = stmtUpdatePass.executeUpdate();
                        
                        if (rowsAffected > 0) {
                            mensagem = "Password alterada com sucesso!";
                            tipoMensagem = "success";
                        } else {
                            mensagem = "Erro ao alterar password!";
                            tipoMensagem = "error";
                        }
                        
                        stmtUpdatePass.close();
                    } else {
                        mensagem = "Password atual incorreta!";
                        tipoMensagem = "error";
                    }
                } else {
                    rsCheck.close();
                    stmtCheck.close();
                    mensagem = "Utilizador não encontrado!";
                    tipoMensagem = "error";
                }
                
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
    <title>SC Rio Tinto - Meu Perfil</title>
    <link href="css/CssPerfil.css" rel="stylesheet" type="text/css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
</head>
<body>
    <div class="container">
        <!-- HEADER -->
        <div class="header">
            <div class="header-left">
                <div class="logo">SC</div>
                <div class="header-title">
                    <h1>Meu Perfil</h1>
                    <p>Gere as tuas informações pessoais</p>
                </div>
            </div>
            <a href="index.htm" class="btn-back">
                <i class="fas fa-arrow-left"></i>
                Voltar ao Início
            </a>
        </div>

        <!-- MENSAGENS -->
        <% if (!mensagem.isEmpty()) { %>
            <div class="message-box <%= tipoMensagem %>">
                <i class="fas fa-<%= tipoMensagem.equals("success") ? "check-circle" : "exclamation-circle" %>"></i>
                <%= mensagem %>
            </div>
        <% } %>

        <!-- GRID PRINCIPAL -->
        <div class="profile-grid">
            <!-- SIDEBAR -->
            <div class="profile-sidebar">
                <div class="profile-avatar">
                    <%= primeiroNome.substring(0, 1).toUpperCase() %><%= ultimoNome.substring(0, 1).toUpperCase() %>
                </div>
                <div class="profile-name">
                    <h2><%= primeiroNome %> <%= ultimoNome %></h2>
                    <p><%= email %></p>
                    <% if (tipoUtilizador.equals("admin")) { %>
                        <span class="profile-badge">
                            <i class="fas fa-crown"></i> ADMINISTRADOR
                        </span>
                    <% } else { %>
                        <span class="profile-badge">
                            <i class="fas fa-user"></i> <%= tipoUtilizador.toUpperCase() %>
                        </span>
                    <% } %>
                </div>
                <div class="profile-stats">
                    <div class="stat-item">
                        <span><i class="fas fa-phone"></i> Telemóvel</span>
                        <strong><%= telefone.isEmpty() ? "N/A" : telefone %></strong>
                    </div>
                    <div class="stat-item">
                        <span><i class="fas fa-birthday-cake"></i> Nascimento</span>
                        <strong><%= dataNascimento.isEmpty() ? "N/A" : dataNascimento %></strong>
                    </div>
                    <div class="stat-item">
                        <span><i class="fas fa-shield-alt"></i> Status</span>
                        <strong style="color: #10B981;">Ativo</strong>
                    </div>
                    <div class="stat-item">
                        <span><i class="fas fa-heart"></i> Tipo</span>
                        <strong><%= tipoUtilizador.substring(0, 1).toUpperCase() + tipoUtilizador.substring(1) %></strong>
                    </div>
                </div>
            </div>

            <!-- CONTEÚDO PRINCIPAL -->
            <div class="profile-content">
                <!-- INFORMAÇÕES PESSOAIS -->
                <div class="card">
                    <div class="card-header">
                        <div class="card-icon">
                            <i class="fas fa-user-edit"></i>
                        </div>
                        <h2>Informações Pessoais</h2>
                    </div>
                    <form method="post">
                        <input type="hidden" name="acao" value="atualizar_perfil">
                        
                        <div class="form-row">
                            <div class="form-group">
                                <label for="primeiro_nome">
                                    <i class="fas fa-user"></i>
                                    Primeiro Nome *
                                </label>
                                <input type="text" name="primeiro_nome" id="primeiro_nome" value="<%= primeiroNome %>" required>
                            </div>

                            <div class="form-group">
                                <label for="ultimo_nome">
                                    <i class="fas fa-user"></i>
                                    Último Nome *
                                </label>
                                <input type="text" name="ultimo_nome" id="ultimo_nome" value="<%= ultimoNome %>" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="email">
                                <i class="fas fa-envelope"></i>
                                Email *
                            </label>
                            <input type="email" name="email" id="email" value="<%= email %>" required>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label for="telefone">
                                    <i class="fas fa-phone"></i>
                                    Telemóvel
                                </label>
                                <input type="tel" name="telefone" id="telefone" value="<%= telefone %>" placeholder="912345678">
                            </div>

                            <div class="form-group">
                                <label for="data_nascimento">
                                    <i class="fas fa-calendar"></i>
                                    Data de Nascimento
                                </label>
                                <input type="date" name="data_nascimento" id="data_nascimento" value="<%= dataNascimento %>">
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="tipo">
                                <i class="fas fa-tag"></i>
                                Tipo de Conta
                            </label>
                            <input type="text" id="tipo" value="<%= tipoUtilizador.substring(0, 1).toUpperCase() + tipoUtilizador.substring(1) %>" disabled>
                        </div>

                        <button type="submit" class="btn-submit">
                            <i class="fas fa-save"></i>
                            Guardar Alterações
                        </button>
                    </form>
                </div>

                <!-- ALTERAR PASSWORD -->
                <div class="card">
                    <div class="card-header">
                        <div class="card-icon">
                            <i class="fas fa-lock"></i>
                        </div>
                        <h2>Alterar Password</h2>
                    </div>
                    <form method="post">
                        <input type="hidden" name="acao" value="alterar_password">
                        
                        <div class="form-group password-toggle">
                            <label for="password_atual">
                                <i class="fas fa-key"></i>
                                Password Atual *
                            </label>
                            <input type="password" name="password_atual" id="password_atual" required>
                            <i class="fas fa-eye toggle-icon" onclick="togglePassword('password_atual')"></i>
                        </div>

                        <div class="form-row">
                            <div class="form-group password-toggle">
                                <label for="nova_password">
                                    <i class="fas fa-lock"></i>
                                    Nova Password *
                                </label>
                                <input type="password" name="nova_password" id="nova_password" required>
                                <i class="fas fa-eye toggle-icon" onclick="togglePassword('nova_password')"></i>
                            </div>

                            <div class="form-group password-toggle">
                                <label for="confirmar_password">
                                    <i class="fas fa-shield-alt"></i>
                                    Confirmar Password *
                                </label>
                                <input type="password" name="confirmar_password" id="confirmar_password" required>
                                <i class="fas fa-eye toggle-icon" onclick="togglePassword('confirmar_password')"></i>
                            </div>
                        </div>

                        <button type="submit" class="btn-submit">
                            <i class="fas fa-key"></i>
                            Alterar Password
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Toggle password visibility
        function togglePassword(inputId) {
            const input = document.getElementById(inputId);
            const icon = input.nextElementSibling;
            
            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.remove('fa-eye');
                icon.classList.add('fa-eye-slash');
            } else {
                input.type = 'password';
                icon.classList.remove('fa-eye-slash');
                icon.classList.add('fa-eye');
            }
        }

        // Auto-hide mensagens após 5 segundos
        setTimeout(() => {
            const messageBox = document.querySelector('.message-box');
            if (messageBox) {
                messageBox.style.animation = 'slideOut 0.5s ease';
                setTimeout(() => {
                    messageBox.style.display = 'none';
                }, 500);
            }
        }, 5000);

        // Adicionar animação de slide out
        const style = document.createElement('style');
        style.textContent = `
            @keyframes slideOut {
                from { transform: translateY(0); opacity: 1; }
                to { transform: translateY(-20px); opacity: 0; }
            }
        `;
        document.head.appendChild(style);

        // Validação em tempo real
        const novaPassword = document.getElementById('nova_password');
        const confirmarPassword = document.getElementById('confirmar_password');

        confirmarPassword.addEventListener('input', () => {
            if (novaPassword.value !== confirmarPassword.value) {
                confirmarPassword.style.borderColor = '#ef4444';
            } else {
                confirmarPassword.style.borderColor = '#10B981';
            }
        });

        // Animação de entrada nos cards
        const cards = document.querySelectorAll('.card');
        cards.forEach((card, index) => {
            card.style.opacity = '0';
            card.style.transform = 'translateY(20px)';
            setTimeout(() => {
                card.style.transition = 'all 0.5s ease';
                card.style.opacity = '1';
                card.style.transform = 'translateY(0)';
            }, index * 100);
        });
    </script>
</body>
</html>