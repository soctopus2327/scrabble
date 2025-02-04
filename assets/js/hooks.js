const Hooks = {
  BoardHook: {
    mounted() {
      this.el.addEventListener('dragover', e => {
        e.preventDefault();
      });

      this.el.addEventListener('drop', e => {
        e.preventDefault();
        const letter = e.dataTransfer.getData('letter');
        const cell = e.target.closest('[data-row]');
        
        if (!cell) return;
        
        const row = parseInt(cell.dataset.row);
        const col = parseInt(cell.dataset.col);

        this.pushEvent('tile-dropped', {
          letter: letter,
          row: row.toString(),
          col: col.toString()
        });
      });
    }
  },

  RackHook: {
    mounted() {
      this.el.addEventListener('dragstart', e => {
        const tile = e.target.closest('.tile');
        if (tile) {
          e.dataTransfer.setData('letter', tile.dataset.letter);
          tile.classList.add('dragging');
        }
      });

      this.el.addEventListener('dragend', e => {
        const tile = e.target.closest('.tile');
        if (tile) {
          tile.classList.remove('dragging');
        }
      });
    }
  },

  SubmitHook: {
    mounted() {
      this.el.addEventListener("click", () => {
        console.log("Submit button clicked") // Debug log
      })
    }
  }
}

export default Hooks;