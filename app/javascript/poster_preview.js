document.addEventListener('turbo:load', initializePosterPreview);
document.addEventListener('DOMContentLoaded', initializePosterPreview);

function initializePosterPreview() {
    const posterInput = document.getElementById('poster_input');
    const posterPreviewDiv = document.getElementById('poster_preview');
    const posterPreviewImage = document.getElementById('poster_preview_image');
    const removePosterCheckbox = document.getElementById('remove_poster_checkbox');

    // Se não encontrar o input de poster, vai sair da função
    if (!posterInput || !posterPreviewDiv || !posterPreviewImage) {
        return;
    }

    posterInput.addEventListener('change', function (e) {
        const file = e.target.files[0];

        if (!file) {
            hidePosterPreview();
            return;
        }

        // --- Aqui estão as validações validações---
        const validTypes = ['image/png', 'image/jpeg', 'image/jpg', 'image/webp'];
        if (!validTypes.includes(file.type)) {
            showError('Formato inválido. Por favor, selecione uma imagem PNG, JPEG ou WebP.');
            posterInput.value = ''
            hidePosterPreview();
            return;
        }

        const maxSize = 5 * 1024 * 1024;
        if (file.size > maxSize) {
            showError('Imagem muito grande. O tamanho máximo permitido é 5MB.');
            posterInput.value = ''
            hidePosterPreview();
            return;
        }

        const reader = new FileReader();

        reader.onload = function (event) {
            posterPreviewImage.src = event.target.result;
            posterPreviewDiv.style.display = 'block';

            // Se existir o checkbox de remoção, desmarca ele, pois um novo arquivo foi selecionado
            if (removePosterCheckbox) {
                removePosterCheckbox.checked = false;

                updateRemovePosterInput(false, posterInput);
            }
        };

        reader.onerror = function () {
            showError('Erro ao carregar a imagem. Tente novamente.');
            hidePosterPreview();
        };

        reader.readAsDataURL(file);
    });

    if (removePosterCheckbox) {
        removePosterCheckbox.addEventListener('change', function () {
            updateRemovePosterInput(this.checked, posterInput);

            // Se marcou para remover, limpa o input de arquivo e esconde o preview
            if (this.checked) {
                posterInput.value = '';
                hidePosterPreview();
            }
        });
    }
}

// Função para esconder a área de preview
function hidePosterPreview() {
    const posterPreviewDiv = document.getElementById('poster_preview');
    const posterPreviewImage = document.getElementById('poster_preview_image');

    if (posterPreviewDiv) {
        posterPreviewDiv.style.display = 'none';
    }

    if (posterPreviewImage) {
        posterPreviewImage.src = ''; // vai limpar a imagem aqui
    }
}

// Função para adicionar/remover o input hidden que sinaliza a remoção
function updateRemovePosterInput(shouldRemove, posterInputElement) {
    if (!posterInputElement) return;
    const form = posterInputElement.closest('form');
    if (!form) return;

    let removeInput = form.querySelector('input[type="hidden"][name="movie[remove_poster]"]');

    if (shouldRemove) {
        // Se deve remover e o input hidden não existe, cria ele
        if (!removeInput) {
            removeInput = document.createElement('input');
            removeInput.type = 'hidden';
            removeInput.name = 'movie[remove_poster]';
            form.appendChild(removeInput);
        }
        removeInput.value = '1';
    } else {
        // Se não deve remover e o input hidden existe, remove ele
        if (removeInput) {
            removeInput.remove();
        }
    }
}


// Função para mostrar mensagens de erro perto do input de poster
function showError(message) {
    const posterInput = document.getElementById('poster_input');
    if (!posterInput || !posterInput.parentElement) return;

    const errorContainer = posterInput.parentElement;

    // Remover erro existente para não acumular mensagens
    const existingError = errorContainer.querySelector('.poster-upload-error');
    if (existingError) {
        existingError.remove();
    }

    // Criar a div de erro
    const errorDiv = document.createElement('div');
    errorDiv.className = 'poster-upload-error alert alert-danger alert-dismissible fade show mt-2';
    errorDiv.style.fontSize = '0.875rem';
    errorDiv.setAttribute('role', 'alert');
    errorDiv.innerHTML = `
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    `;

    const formText = errorContainer.querySelector('.form-text');
    if (formText && formText.nextSibling) {
        errorContainer.insertBefore(errorDiv, formText.nextSibling);
    } else {
        errorContainer.appendChild(errorDiv);
    }


    // Remover automaticamente após 5 segundos
    setTimeout(() => {
        errorDiv.style.transition = 'opacity 0.5s ease';
        errorDiv.style.opacity = '0';
        setTimeout(() => {
            errorDiv.remove();
        }, 500);
    }, 5000);
}