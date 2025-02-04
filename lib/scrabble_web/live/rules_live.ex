# defmodule ScrabbleWeb.RulesLive do
#   use ScrabbleWeb, :live_view

#   def mount(_params, _session, socket) do
#     {:ok, socket}
#   end

#   def render(assigns) do
#     ~H"""
#     <div class="min-h-screen bg-green-50 py-12">
#       <div class="container mx-auto px-4 max-w-3xl">
#         <div class="text-center mb-8">
#           <h1 class="text-4xl font-bold text-green-800 mb-4">Scrabble Rules</h1>
#           <a href="/" class="text-green-600 hover:text-green-700 underline">
#             Back to Home
#           </a>
#         </div>

#         <div class="bg-white rounded-lg shadow-lg p-8 space-y-6">
#           <section>
#             <h2 class="text-2xl font-bold text-green-800 mb-3">Game Setup</h2>
#             <p class="text-gray-700">Each player draws 7 tiles. The player with the letter closest to "A" goes first.</p>
#           </section>

#           <section>
#             <h2 class="text-2xl font-bold text-green-800 mb-3">Basic Rules</h2>
#             <ul class="list-disc pl-6 text-gray-700 space-y-2">
#               <li>Players take turns placing words on the board</li>
#               <li>Words must connect to existing tiles</li>
#               <li>All words formed must be valid</li>
#               <li>Score points based on letter values and board multipliers</li>
#             </ul>
#           </section>

#           <section>
#             <h2 class="text-2xl font-bold text-green-800 mb-3">Scoring</h2>
#             <ul class="list-disc pl-6 text-gray-700 space-y-2">
#               <li>Each letter has a point value (shown on the tile)</li>
#               <li>Colored squares multiply letter or word scores</li>
#               <li>Using all 7 tiles adds 50 bonus points</li>
#             </ul>
#           </section>

#           <section>
#             <h2 class="text-2xl font-bold text-green-800 mb-3">Game End</h2>
#             <p class="text-gray-700">The game ends when all tiles are used or no more plays can be made.</p>
#           </section>
#         </div>
#       </div>
#     </div>
#     """
#   end
# end
defmodule ScrabbleWeb.RulesLive do
  use ScrabbleWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-100 py-6 flex flex-col justify-center sm:py-12">
      <div class="relative py-3 sm:max-w-xl sm:mx-auto">
        <div class="relative px-4 py-10 bg-white shadow-lg sm:rounded-3xl sm:p-20">
          <div class="max-w-md mx-auto">
            <h1 class="text-3xl font-bold mb-8">Scrabble Rules</h1>

            <div class="prose">
              <h2 class="text-xl font-semibold mb-4">Basic Rules</h2>
              <ul class="list-disc pl-5 space-y-2">
                <li>Players take turns placing words on the board</li>
                <li>Words can be placed horizontally or vertically</li>
                <li>All words must connect to existing words</li>
                <li>Points are awarded based on letter values and board multipliers</li>
              </ul>

              <div class="mt-8">
                <.link
                  navigate="/"
                  class="inline-block px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600"
                >
                  Back to Home
                </.link>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
