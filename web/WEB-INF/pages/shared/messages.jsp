<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage = (String) session.getAttribute("errorMessage");
    String warningMessage = (String) session.getAttribute("warningMessage");
    String infoMessage = (String) session.getAttribute("infoMessage");
    
    // Limpiar mensajes después de mostrarlos
    if (successMessage != null) session.removeAttribute("successMessage");
    if (errorMessage != null) session.removeAttribute("errorMessage");
    if (warningMessage != null) session.removeAttribute("warningMessage");
    if (infoMessage != null) session.removeAttribute("infoMessage");
%>

<% if (successMessage != null) { %>
    <div class="alert alert-success">
        <div class="alert-content">
            <span class="alert-icon">✅</span>
            <span class="alert-message"><%= successMessage %></span>
            <button class="alert-close" onclick="this.parentElement.parentElement.style.display='none'">×</button>
        </div>
    </div>
<% } %>

<% if (errorMessage != null) { %>
    <div class="alert alert-error">
        <div class="alert-content">
            <span class="alert-icon">❌</span>
            <span class="alert-message"><%= errorMessage %></span>
            <button class="alert-close" onclick="this.parentElement.parentElement.style.display='none'">×</button>
        </div>
    </div>
<% } %>

<% if (warningMessage != null) { %>
    <div class="alert alert-warning">
        <div class="alert-content">
            <span class="alert-icon">⚠️</span>
            <span class="alert-message"><%= warningMessage %></span>
            <button class="alert-close" onclick="this.parentElement.parentElement.style.display='none'">×</button>
        </div>
    </div>
<% } %>

<% if (infoMessage != null) { %>
    <div class="alert alert-info">
        <div class="alert-content">
            <span class="alert-icon">ℹ️</span>
            <span class="alert-message"><%= infoMessage %></span>
            <button class="alert-close" onclick="this.parentElement.parentElement.style.display='none'">×</button>
        </div>
    </div>
<% } %>

<script>
    // Auto-close alerts after 5 seconds
    document.addEventListener('DOMContentLoaded', function() {
        const alerts = document.querySelectorAll('.alert');
        alerts.forEach(alert => {
            setTimeout(() => {
                alert.style.display = 'none';
            }, 5000);
        });
    });
</script>