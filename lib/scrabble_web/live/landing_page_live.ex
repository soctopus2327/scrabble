defmodule ScrabbleWeb.LandingPageLive do
  use ScrabbleWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-100 py-6 flex flex-col justify-center sm:py-12">
      <div class="relative py-3 sm:max-w-xl sm:mx-auto">
        <div class="relative px-4 py-10 bg-white shadow-lg sm:rounded-3xl sm:p-20">
          <div class="max-w-md mx-auto">
            <div class="divide-y divide-gray-200">
              <div class="py-8 text-base leading-6 space-y-4 text-gray-700 sm:text-lg sm:leading-7">
                <h1 class="text-3xl font-bold text-center mb-8">Welcome to Scrabble</h1>
                <div class="flex flex-col space-y-4">
                  <.link
                    navigate="/login"
                    class="px-4 py-2 bg-blue-500 text-white rounded-md text-center hover:bg-blue-600"
                  >
                    Play Now
                  </.link>
                  <.link
                    navigate="/rules"
                    class="px-4 py-2 bg-gray-500 text-white rounded-md text-center hover:bg-gray-600"
                  >
                    View Rules
                  </.link>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
