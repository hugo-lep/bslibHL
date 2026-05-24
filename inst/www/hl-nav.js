/* bslibHL — routing sidebar, dropdown toggle, compatibilité protegR2
   Chargé automatiquement via htmlDependency() */

$(function () {

  /* ── Boutons de navigation ──────────────────────────────────────────────
     Clic sur .hl-nav-btn → envoie la valeur à Shiny (hl__nav)
     page_sidebarHL_server() écoute cet input, appelle nav_select() et
     met à jour l'URL (?page=valeur).
  -------------------------------------------------------------------------- */
  $(document).on("click", ".hl-nav-btn", function () {
    var value = $(this).data("value");

    // Informer Shiny
    Shiny.setInputValue("hl__nav", value, { priority: "event" });

    // État visuel actif
    $(".hl-nav-btn").removeClass("active");
    $(this).addClass("active");

    // Marquer le groupe parent si applicable
    $(".hl-nav-group-btn").removeClass("has-active-child");
    var $group = $(this).closest(".hl-nav-group-children");
    if ($group.length) {
      $group.siblings(".hl-nav-group-btn").addClass("has-active-child");
    }
  });

  /* ── Toggle groupe collapsible ──────────────────────────────────────────
     Clic sur .hl-nav-group-btn → expand/collapse les enfants
  -------------------------------------------------------------------------- */
  $(document).on("click", ".hl-nav-group-btn", function () {
    $(this).toggleClass("expanded");
    $(this).next(".hl-nav-group-children").slideToggle(180);
  });

  /* ── Activation programmatique d'un panneau depuis le serveur ───────────
     Appelé via hl_nav_select(value, session) côté serveur.
     Met à jour les classes CSS de la sidebar sans clic utilisateur :
       - retire "active" de tous les boutons
       - ajoute "active" sur le bouton cible
       - gère les groupes collapsibles (expand + has-active-child)
     Utile pour la restauration d'onglet depuis l'URL au démarrage.
  -------------------------------------------------------------------------- */
  Shiny.addCustomMessageHandler("hl_set_active", function (msg) {
    var $btn = $(".hl-nav-btn[data-value='" + msg.value + "']");

    // Mettre à jour l'état actif de tous les boutons
    $(".hl-nav-btn").removeClass("active");
    $btn.addClass("active");

    // Mettre à jour les groupes
    $(".hl-nav-group-btn").removeClass("has-active-child expanded");
    var $group = $btn.closest(".hl-nav-group-children");
    if ($group.length) {
      var $groupBtn = $group.siblings(".hl-nav-group-btn");
      $groupBtn.addClass("has-active-child expanded");
      // S'assurer que le groupe est visible (au cas où il était replié)
      $group.show();
    }
  });

});
