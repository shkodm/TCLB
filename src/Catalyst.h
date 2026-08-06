#ifndef FEADAPTOR_HEADER
#define FEADAPTOR_HEADER

class Solver;

namespace CatalystAdaptor
{
  int Initialize(bool exportCellData);
  int AddScript(const char * script);
  
  int Finalize();

  int CoProcess(Solver& grid, double time,
                unsigned int timeStep, bool lastTimeStep);
}

#endif
