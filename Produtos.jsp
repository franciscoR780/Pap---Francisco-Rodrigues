<%--
    Document   : Produtos
    Created on : 05/11/2025, 14:56:31
    Author     : Francisco
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<%
    // Verificar sessão
    Integer idUtilizador = (Integer) session.getAttribute("id_utilizador");
    String primeiroNome = (String) session.getAttribute("primeiro_nome");
    String ultimoNome = (String) session.getAttribute("ultimo_nome");
    String emailUtilizador = (String) session.getAttribute("email");
    Boolean isAdmin = (Boolean) session.getAttribute("is_admin");
    
    if (isAdmin == null) isAdmin = false;
    boolean estaLogado = (idUtilizador != null);
    
    // Verificar se é sócio
    boolean jaSocio = false;
    String numeroSocio = null;
    
    if (estaLogado) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection connSocio = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
            PreparedStatement pstmt = connSocio.prepareStatement(
                "SELECT numero_socio FROM t_socio WHERE id_utilizador = ?");
            pstmt.setInt(1, idUtilizador);
            ResultSet rsSocio = pstmt.executeQuery();
            
            if (rsSocio.next()) {
                jaSocio = true;
                numeroSocio = rsSocio.getString("numero_socio");
            }
            
            rsSocio.close();
            pstmt.close();
            connSocio.close();
        } catch (Exception e) {
            out.println("<!-- Erro ao verificar sócio: " + e.getMessage() + " -->");
        }
    }
    
    double descontoSocio = jaSocio ? 0.15 : 0.0; // 15% desconto para sócios
%>

<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SC Rio Tinto - Loja Oficial</title>
    <link href="css/CssProdutos.css" rel="stylesheet" type="text/css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@100;200;300;400;500;600;700;800;900&display=swap" rel="stylesheet">
</head>

<body>
    <!-- HEADER -->
    <header id="header">
        <div class="logo-container" onclick="window.location.href='index.htm'">
            <div class="logo-icon">SC</div>
            <span>Rio Tinto</span>
        </div>
        <nav>
            <ul>
                <li><a href="index.htm">Home</a></li>
                <li><a href="noticias-formacao.jsp">Formação</a></li>        
                <li><a href="Produtos.jsp">Produtos</a></li>
                <li><a href="Bilheteria.jsp">Bilheteria</a></li>
                <li><a href="Socios front page.jsp">Sócios</a></li>
                <li><a href="Equipas.jsp">Equipas</a></li>
                <li><a href="Sobre.jsp">Sobre</a></li>
                <li>
                    <% if (estaLogado) { %>
                        <div class="user-dropdown">
                            <button class="btn-header">
                                <i class="fas fa-user-circle"></i>
                                <%= primeiroNome %>
                                <% if (isAdmin) { %>
                                    <span class="admin-badge">ADMIN</span>
                                <% } %>
                                <% if (jaSocio) { %>
                                    <span class="socio-badge">✓ SÓCIO</span>
                                <% } %>
                                <i class="fas fa-chevron-down" style="font-size: 0.8rem;"></i>
                            </button>
                            <div class="dropdown-menu">
                                <div class="dropdown-header">
                                    <div class="user-name">
                                        <%= primeiroNome %> <%= ultimoNome %>
                                        <% if (jaSocio) { %>
                                            <span class="socio-badge">✓ SÓCIO</span>
                                        <% } %>
                                    </div>
                                    <div class="user-email"><%= emailUtilizador %></div>
                                    <% if (jaSocio) { %>
                                        <div style="margin-top: 0.5rem; padding-top: 0.5rem; border-top: 1px solid rgba(255, 215, 0, 0.2);">
                                            <div style="color: var(--amarelo); font-size: 0.75rem; font-weight: 600;">
                                                <i class="fas fa-id-card"></i> Nº <%= numeroSocio %>
                                            </div>
                                        </div>
                                    <% } %>
                                </div>
                                <a href="perfil.jsp" class="dropdown-item">
                                    <i class="fas fa-user"></i>
                                    Meu Perfil
                                </a>
                                <% if (jaSocio) { %>
                                    <a href="cartao-socio.jsp" class="dropdown-item">
                                        <i class="fas fa-id-card"></i>
                                        Cartão de Sócio
                                    </a>
                                <% } else { %>
                                    <a href="Socios front page.jsp" class="dropdown-item" style="background: rgba(16, 185, 129, 0.1);">
                                        <i class="fas fa-user-plus"></i>
                                        Tornar-me Sócio
                                    </a>
                                <% } %>
                                <a href="pedidos.jsp" class="dropdown-item">
                                    <i class="fas fa-shopping-bag"></i>
                                    Meus Pedidos
                                </a>
                                <a href="MeusBilhetes.jsp" class="dropdown-item">
                                    <i class="fas fa-ticket"></i>
                                    Meus Bilhetes
                                </a>
                                <% if (isAdmin) { %>
                                    <div class="dropdown-divider"></div>
                                    <a href="admin.jsp" class="dropdown-item">
                                        <i class="fas fa-crown"></i>
                                        Painel Admin
                                    </a>
                                <% } %>
                                <div class="dropdown-divider"></div>
                                <a href="logout.jsp" class="dropdown-item logout">
                                    <i class="fas fa-sign-out-alt"></i>
                                    Terminar Sessão
                                </a>
                            </div>
                        </div>
                    <% } else { %>
                        <div class="user-dropdown">
                            <button class="btn-header">
                                <i class="fas fa-user"></i>
                                Conta
                                <i class="fas fa-chevron-down" style="font-size: 0.8rem;"></i>
                            </button>
                            <div class="dropdown-menu">
                                <a href="Login.jsp" class="dropdown-item">
                                    <i class="fas fa-sign-in-alt"></i>
                                    Iniciar Sessão
                                </a>
                                <a href="Registro.jsp" class="dropdown-item">
                                    <i class="fas fa-user-plus"></i>
                                    Criar Conta
                                </a>
                            </div>
                        </div>
                    <% } %>
                </li>
                <li>
                    <button class="cart-button" id="cart-toggle">
                        <i class="fas fa-shopping-cart"></i>
                        
                        <span class="cart-count" id="cart-count">0</span>
                    </button>
                </li>
            </ul>
        </nav>
    </header>

    <!-- BANNER SÓCIO -->
    <% if (jaSocio) { %>
        <div class="socio-banner">
            <i class="fas fa-star"></i>
            Parabéns! Como sócio, tens 15% de desconto em todos os produtos!
            <i class="fas fa-star"></i>
        </div>
    <% } %>

    <!-- HERO SECTION -->
    <section class="hero" style="<%= jaSocio ? "margin-top: 0;" : "" %>">
        <div class="hero-content">
            <span class="hero-badge">
                <i class="fas fa-star"></i> Coleção Oficial 2025/26
            </span>
            <h1>Loja Oficial</h1>
            <p>
                Descobre a nossa coleção exclusiva de produtos oficiais do SC Rio Tinto. 
                Veste as cores da paixão e leva contigo o orgulho do nosso clube!
            </p>
        </div>
    </section>

    <!-- FILTERS SECTION -->
    <section class="filters-section">
        <div class="filters-container">
            <div class="filter-group">
                <button class="filter-btn active" data-categoria="todos">
                    <i class="fas fa-th"></i> Todos
                </button>
                <button class="filter-btn" data-categoria="equipamentos">
                    <i class="fas fa-tshirt"></i> Equipamentos
                </button>
                <button class="filter-btn" data-categoria="acessorios">
                    <i class="fas fa-hat-cowboy"></i> Acessórios
                </button>
            </div>
            <input type="text" class="search-box" placeholder="🔍 Pesquisar produtos..." id="search-input">
        </div>
    </section>

    <!-- PRODUTOS SECTION -->
    <section class="produtos-section">
        <div class="produtos-container">
            <div class="produtos-grid" id="produtos-grid">
                <%
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        Connection conn = DriverManager.getConnection(
                            "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", 
                            "root", 
                            ""
                        );
                        Statement stmt = conn.createStatement();
                        
                        String query = "SELECT p.id_produto, p.nome_produto, p.descricao, p.preco, p.stock, " +
                                      "p.temporada, p.imagem_principal, p.id_categoria, c.nome as nome_categoria " +
                                      "FROM t_produtos p " +
                                      "LEFT JOIN t_categoria c ON p.id_categoria = c.id_categoria " +
                                      "ORDER BY p.id_produto";
                        
                        ResultSet rs = stmt.executeQuery(query);
                        
                        while (rs.next()) {
                            int idProduto = rs.getInt("id_produto");
                            String nomeProduto = rs.getString("nome_produto");
                            String descricao = rs.getString("descricao");
                            double precoOriginal = rs.getDouble("preco");
                            int stock = rs.getInt("stock");
                            String temporada = rs.getString("temporada");
                            String imagemPrincipal = rs.getString("imagem_principal");
                            int idCategoria = rs.getInt("id_categoria");
                            String nomeCategoria = rs.getString("nome_categoria");
                            
                            // Calcular preço com desconto para sócios
                            double precoFinal = precoOriginal;
                            double valorEconomizado = 0;
                            
                            if (jaSocio) {
                                precoFinal = precoOriginal * (1 - descontoSocio);
                                valorEconomizado = precoOriginal - precoFinal;
                            }
                            
                            // Determinar categoria para filtro
                            String categoriaFiltro = "equipamentos";
                            
                            if (nomeCategoria != null) {
                                String nomeCategLower = nomeCategoria.toLowerCase();
                                
                                if (nomeCategLower.contains("camisola") || 
                                    nomeCategLower.contains("equipamento") || 
                                    idCategoria == 6) {
                                    categoriaFiltro = "equipamentos";
                                } else if (nomeCategLower.contains("acessório") || 
                                           nomeCategLower.contains("acessorio") ||
                                           nomeCategLower.contains("boné") || 
                                           nomeCategLower.contains("bone") ||
                                           idCategoria == 7) {
                                    categoriaFiltro = "acessorios";
                                } else if (nomeCategLower.contains("memorabilia")) {
                                    categoriaFiltro = "memorabilia";
                                }
                            }
                            
                            boolean isNovo = temporada != null && (temporada.contains("2025") || temporada.contains("2026"));
                            String categoriaNomeExibir = nomeCategoria != null ? nomeCategoria : "Equipamentos";
                %>
                            <div class="produto-card" 
                                 data-categoria="<%= categoriaFiltro %>" 
                                 data-id="<%= idProduto %>"
                                 data-nome="<%= nomeProduto %>"
                                 data-preco="<%= precoFinal %>"
                                 data-imagem="<%= imagemPrincipal != null ? imagemPrincipal : "" %>">
                                <div class="produto-image">
                                    <% if (isNovo) { %>
                                        <div class="produto-badge">
                                            <i class="fas fa-bolt"></i> Novo
                                        </div>
                                    <% } %>
                                    <% if (jaSocio) { %>
                                        <div class="desconto-badge">
                                            <i class="fas fa-percent"></i> -15%
                                        </div>
                                    <% } %>
                                    <% if (imagemPrincipal != null && !imagemPrincipal.isEmpty()) { %>
                                        <img src="<%= imagemPrincipal %>" 
                                             alt="<%= nomeProduto %>" 
                                             onerror="this.parentElement.innerHTML='<i class=\'fas fa-tshirt\' style=\'font-size: 4rem; color: #FFD700;\'></i>'">
                                    <% } else { %>
                                        <i class="fas fa-tshirt" style="font-size: 4rem; color: #FFD700;"></i>
                                    <% } %>
                                </div>
                                <div class="produto-info">
                                    <div class="produto-categoria">
                                        <i class="fas fa-tag"></i> <%= categoriaNomeExibir %>
                                    </div>
                                    <h3 class="produto-nome"><%= nomeProduto %></h3>
                                    <p class="produto-descricao"><%= descricao != null ? descricao : "" %></p>
                                    
                                    <div class="produto-preco">
                                        <% if (jaSocio) { %>
                                            <span class="preco-original">
                                                <%= String.format("%.2f", precoOriginal) %>€
                                            </span>
                                            <span class="preco-atual">
                                                <%= String.format("%.2f", precoFinal) %>€
                                            </span>
                                            <span class="economia-text">
                                                <i class="fas fa-piggy-bank"></i>
                                                Economizas <%= String.format("%.2f", valorEconomizado) %>€
                                            </span>
                                        <% } else { %>
                                            <span class="preco-atual">
                                                <%= String.format("%.2f", precoOriginal) %>€
                                            </span>
                                        <% } %>
                                    </div>
                                    
                                    <div class="produto-stock">
                                        <% if (stock > 0) { %>
                                            <i class="fas fa-check-circle" style="color: #4CAF50;"></i> 
                                            <%= stock %> em stock
                                        <% } else { %>
                                            <i class="fas fa-times-circle" style="color: #f44336;"></i> 
                                            Esgotado
                                        <% } %>
                                    </div>
                                    
                                    <button class="btn-add-cart" 
                                            onclick="adicionarAoCarrinho(<%= idProduto %>, '<%= nomeProduto.replace("'", "\\'") %>', <%= precoFinal %>, '<%= imagemPrincipal != null ? imagemPrincipal.replace("'", "\\'") : "" %>')" 
                                            <% if (stock == 0) { %>disabled<% } %>>
                                        <i class="fas fa-<%= stock == 0 ? "ban" : "cart-plus" %>"></i>
                                        <%= stock == 0 ? "Esgotado" : "Adicionar ao Carrinho" %>
                                    </button>
                                </div>
                            </div>
                <%
                        }
                        rs.close();
                        stmt.close();
                        conn.close();
                    } catch (Exception e) {
                        out.println("<div style='grid-column: 1/-1; text-align: center; padding: 3rem; color: red;'>");
                        out.println("<h3>⚠️ Erro ao carregar produtos</h3>");
                        out.println("<p>" + e.getMessage() + "</p>");
                        out.println("</div>");
                        e.printStackTrace();
                    }
                %>
            </div>
        </div>
    </section>

    <!-- CART SIDEBAR -->
    <div class="cart-sidebar" id="cart-sidebar">
        <div class="cart-header">
            <h2 class="cart-title">
                <i class="fas fa-shopping-bag"></i> Carrinho
            </h2>
            <button class="cart-close" id="cart-close">
                <i class="fas fa-times"></i>
            </button>
        </div>
        <div class="cart-items" id="cart-items">
            <div style="text-align: center; padding: 3rem; color: #999;">
                <i class="fas fa-shopping-cart" style="font-size: 3rem; color: #ddd; margin-bottom: 1rem;"></i>
                <p>Carrinho vazio</p>
            </div>
        </div>
        <div class="cart-total">
            <div class="total-row">
                <span>Total:</span>
                <span id="cart-total" style="color: #FFA000;">0.00€</span>
            </div>
            <button class="btn-checkout" id="checkout-btn">
                <i class="fas fa-credit-card"></i>
                Finalizar Compra
            </button>
        </div>
    </div>

    <!-- OVERLAY -->
    <div class="cart-overlay" id="cart-overlay"></div>

    <!-- JAVASCRIPT -->
    <script>
        // VARIABLES
        let carrinho = [];
        let filtroAtual = 'todos';

        // LOAD CART FROM LOCALSTORAGE
        window.addEventListener('load', () => {
            const carrinhoSalvo = localStorage.getItem('carrinho');
            if (carrinhoSalvo) {
                try {
                    carrinho = JSON.parse(carrinhoSalvo);
                    atualizarCarrinho();
                } catch (e) {
                    console.error('Erro ao carregar carrinho:', e);
                    localStorage.removeItem('carrinho');
                }
            }
        });

        // ADD TO CART
        function adicionarAoCarrinho(id, nome, preco, imagem) {
            const itemExistente = carrinho.find(item => item.id === id);

            if (itemExistente) {
                itemExistente.quantidade++;
            } else {
                carrinho.push({
                    id: id,
                    id_produto: id,
                    nome: nome,
                    preco: preco,
                    imagem: imagem,
                    quantidade: 1
                });
            }

            salvarCarrinho();
            atualizarCarrinho();
            mostrarNotificacao('✓ ' + nome + ' adicionado ao carrinho!', 'success');

            setTimeout(() => {
                document.getElementById('cart-sidebar').classList.add('active');
                document.getElementById('cart-overlay').classList.add('active');
            }, 500);
        }

        // UPDATE CART
        function atualizarCarrinho() {
            const cartCount = document.getElementById('cart-count');
            const cartItems = document.getElementById('cart-items');
            const cartTotal = document.getElementById('cart-total');

            const totalItens = carrinho.reduce((sum, item) => sum + item.quantidade, 0);
            const totalPreco = carrinho.reduce((sum, item) => sum + (item.preco * item.quantidade), 0);

            cartCount.textContent = totalItens;
            cartTotal.textContent = totalPreco.toFixed(2) + '€';

            if (carrinho.length === 0) {
                cartItems.innerHTML = '<div style="text-align: center; padding: 3rem; color: #999;">' +
                    '<i class="fas fa-shopping-cart" style="font-size: 3rem; color: #ddd; margin-bottom: 1rem;"></i>' +
                    '<p>Carrinho vazio</p></div>';
            } else {
                cartItems.innerHTML = carrinho.map(item => {
                    const imagemHtml = item.imagem ? 
                        '<img src="' + item.imagem + '" alt="' + item.nome + '">' : 
                        '<i class="fas fa-tshirt" style="font-size: 2rem; color: #FFD700;"></i>';

                    return '<div class="cart-item">' +
                        '<div class="item-image">' + imagemHtml + '</div>' +
                        '<div class="item-info">' +
                            '<div class="item-name">' + item.nome + '</div>' +
                            '<div class="item-price">' + item.preco.toFixed(2) + '€</div>' +
                            '<div class="item-quantity">' +
                                '<button class="qty-btn" onclick="alterarQuantidade(' + item.id + ', -1)">−</button>' +
                                '<span style="font-weight: 700; font-size: 1.1rem;">' + item.quantidade + '</span>' +
                                '<button class="qty-btn" onclick="alterarQuantidade(' + item.id + ', 1)">+</button>' +
                                '<button class="btn-remove" onclick="removerDoCarrinho(' + item.id + ')">' +
                                    '<i class="fas fa-trash"></i>' +
                                '</button>' +
                            '</div>' +
                        '</div>' +
                    '</div>';
                }).join('');
            }
        }

        // CHANGE QUANTITY
        function alterarQuantidade(produtoId, delta) {
            const item = carrinho.find(item => item.id === produtoId);
            if (!item) return;

            const novaQuantidade = item.quantidade + delta;

            if (novaQuantidade <= 0) {
                removerDoCarrinho(produtoId);
                return;
            }

            item.quantidade = novaQuantidade;
            salvarCarrinho();
            atualizarCarrinho();
        }

        // REMOVE FROM CART
        function removerDoCarrinho(produtoId) {
            carrinho = carrinho.filter(item => item.id !== produtoId);
            salvarCarrinho();
            atualizarCarrinho();
            mostrarNotificacao('✓ Item removido do carrinho', 'info');
        }

        // SAVE CART
        function salvarCarrinho() {
            localStorage.setItem('carrinho', JSON.stringify(carrinho));
        }

        // FILTER PRODUCTS
        function filtrarProdutos() {
            const searchTerm = document.getElementById('search-input').value.toLowerCase();
            const cards = document.querySelectorAll('.produto-card');

            cards.forEach(card => {
                const categoria = card.getAttribute('data-categoria');
                const nome = card.getAttribute('data-nome').toLowerCase();

                const matchCategoria = filtroAtual === 'todos' || categoria === filtroAtual;
                const matchSearch = !searchTerm || nome.includes(searchTerm);

                if (matchCategoria && matchSearch) {
                    card.style.display = 'block';
                } else {
                    card.style.display = 'none';
                }
            });
        }

        // FILTER BUTTONS
        document.querySelectorAll('.filter-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
                btn.classList.add('active');
                filtroAtual = btn.getAttribute('data-categoria');
                filtrarProdutos();
            });
        });

        // SEARCH INPUT
        document.getElementById('search-input').addEventListener('input', filtrarProdutos);

        // CART TOGGLE
        document.getElementById('cart-toggle').addEventListener('click', (e) => {
            e.preventDefault();
            document.getElementById('cart-sidebar').classList.add('active');
            document.getElementById('cart-overlay').classList.add('active');
        });

        document.getElementById('cart-close').addEventListener('click', () => {
            document.getElementById('cart-sidebar').classList.remove('active');
            document.getElementById('cart-overlay').classList.remove('active');
        });

        document.getElementById('cart-overlay').addEventListener('click', () => {
            document.getElementById('cart-sidebar').classList.remove('active');
            document.getElementById('cart-overlay').classList.remove('active');
        });

        // CHECKOUT
        document.getElementById('checkout-btn').addEventListener('click', () => {
            if (carrinho.length === 0) {
                mostrarNotificacao('⚠️ Carrinho vazio! Adicione produtos antes de finalizar.', 'error');
                return;
            }
            window.location.href = 'pagamento.jsp';
        });

        // NOTIFICATIONS
        function mostrarNotificacao(mensagem, tipo = 'success') {
            const notification = document.createElement('div');
            notification.className = 'notification show';
            
            const icon = tipo === 'success' ? 'check-circle' : 
                        tipo === 'error' ? 'exclamation-circle' : 'info-circle';
            
            notification.innerHTML = '<i class="fas fa-' + icon + '"></i><span>' + mensagem + '</span>';

            if (tipo === 'error') {
                notification.style.background = 'linear-gradient(135deg, #f44336, #e53935)';
            } else if (tipo === 'info') {
                notification.style.background = 'linear-gradient(135deg, #FFD700, #FFA000)';
                notification.style.color = 'var(--preto)';
            }

            document.body.appendChild(notification);

            setTimeout(() => {
                notification.classList.remove('show');
                setTimeout(() => {
                    if (document.body.contains(notification)) {
                        document.body.removeChild(notification);
                    }
                }, 400);
            }, 3000);
        }

        // ESC KEY TO CLOSE CART
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                document.getElementById('cart-sidebar').classList.remove('active');
                document.getElementById('cart-overlay').classList.remove('active');
            }
        });

        // Header scroll effect
        const header = document.getElementById("header");
        let lastScrollY = window.scrollY;
        
        window.addEventListener("scroll", () => {
            const currentScrollY = window.scrollY;
            
            if (currentScrollY > 50) {
                header.classList.add("scrolled");
            } else {
                header.classList.remove("scrolled");
            }
            
            lastScrollY = currentScrollY;
        });

        console.log('🛒 Loja SC Rio Tinto carregada!');
        console.log('💛 Força Rio Tinto! 💛');
    </script>
</body>
</html>