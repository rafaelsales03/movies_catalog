document.addEventListener('turbo:load', initializeCategorySelection);
document.addEventListener('DOMContentLoaded', initializeCategorySelection);

function initializeCategorySelection() {
    const container = document.getElementById('categories-container');
    if (!container) return;

    const labels = container.querySelectorAll('.category-checkbox-label');

    labels.forEach((label) => {
        const checkbox = label.querySelector('.category-checkbox');
        const button = label.querySelector('.category-button');

        if (!checkbox || !button) return;

        // Vai remover qualquer listener anterior
        label.replaceWith(label.cloneNode(true));
    });

    // Seleciona de novo depois de clonar
    const newLabels = container.querySelectorAll('.category-checkbox-label');

    newLabels.forEach((label) => {
        const checkbox = label.querySelector('.category-checkbox');
        const button = label.querySelector('.category-button');

        if (!checkbox || !button) return;

        // Ele vai sincronizar o estado inicial
        syncButtonState(checkbox, button);

        // Evento de clique no label
        label.addEventListener('click', (e) => {
            // Previne o comportamento padrão
            e.preventDefault();
            e.stopPropagation();

            // Alterna manualmente o checkbox
            checkbox.checked = !checkbox.checked;

            // Aqui ele sincroniza o visual do botão
            syncButtonState(checkbox, button);

            // Atualiza lista de categorias selecionadas
            updateSelectedCategories();
        });
    });

    updateSelectedCategories();
}

function syncButtonState(checkbox, button) {
    if (checkbox.checked) {
        button.classList.add('active');
    } else {
        button.classList.remove('active');
    }
}

function updateSelectedCategories() {
    const container = document.getElementById('categories-container');
    if (!container) return;

    const checkboxes = container.querySelectorAll('.category-checkbox:checked');
    const selectedContainer = document.getElementById('selected-categories');

    if (!selectedContainer) return;

    if (checkboxes.length > 0) {
        const names = Array.from(checkboxes).map((cb) => {
            const label = cb.closest('.category-checkbox-label');
            const button = label.querySelector('.category-button');
            return button.textContent.trim();
        });

        selectedContainer.innerHTML =
            'Selecionadas: ' +
            names.join(', ');
    } else {
        selectedContainer.innerHTML =
            'Clique nos botões para selecionar as categorias do filme.';
    }
}